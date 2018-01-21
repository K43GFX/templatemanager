class CloneController < ApplicationController
  #before_action :set_clone, only: [:show, :edit, :update, :destroy]

  @@apiserver = "http://#{Setting.first.apiserver}:#{Setting.first.apiport}"

  # GET /clones
  # GET /clones.json
  def index
    @clone = Clone.new
    @templates = VM.where(purpose: 'template')
  end

  def new
    @clone = Clone.new
    @templates = VM.where(purpose: 'template')
  end

  def create

    options = Hash.new
    logger.info "========================="
    begin

      # Check if new template name is submitted
      if params[:nickname].present?
        template = params[:nickname]
      else
        raise StandardError.new("New template name wasn't submitted!")
      end

      # Check if parent template is present and accessible
      @dolly = VM.find_by(identifier: params[:template])

      if @dolly.present?
        logger.info "#{params['nickname']}: attempting to create clone from image #{params['template']}"
        image = params[:template]
      else
        raise StandardError.new("Parent template was not found!")
      end

      # Change machine state to poweroff before cloning / snapshotting
      logger.info "Attempting to power off #{params[:template]}"
      @dolly.set_state('poweroff')

      # Check if machine was successfully powered off
      until VM.find_by(identifier: params[:template]).state == "poweroff" do
        logger.info "#{params[:template]} still not powered off, sending new shutdown request"
        @dolly.set_state('poweroff')
      end
      logger.info "#{params[:template]} is powered off"

      # Create new snapshot of parent template in case it was requested
      if params[:newsnapshot].present?
        logger.info "New snapshot was requested. Attempting to create Snapshot."

        snapshotname = "#{params[:template]}-#{Time.now.strftime("%H%M%m%y")}"
        snapshotted = Snapshot.make(params[:template], snapshotname)

        if snapshotted
          logger.info "Snapshot #{snapshotted} successfully created."
        else
          StandardError.new("Error when creating new snapshot")
        end

      else
        logger.info "New snapshot was not requested. Proceeding to cloning."
      end

      #logger.info "Ready to create machine"
      #logger.info "Name: #{template}"
      #logger.info "Image: #{image}"
      #logger.info "Options: #{options}"

      # Clone machine with gathered data
      logger.info "Creating new machine #{template} from template #{image}..."

      basicoptions = Hash.new
      basicoptions["image"] = image
      #basicoptions["state"] = "running"
      cloned = VM.clone(template, basicoptions)

      if cloned.key? 'machine'
        logger.info "VM template was cloned successfully."
      else
        if cloned.key? 'error'
          StandardError.new("Error when cloning unmodified VM template: #{cloned["error"]}")
        else
          logger.info "Unknown error when clonining unmodified VM template"
        end
      end

      # Check if any new DMI properties are being added
      logger.info "Attempting to detect additional DMI properties"
      
      if params[:dmiproperty].present?
        dmi = Hash.new
        dmis = params[:dmiproperty]
        dmis.each do |property,value|
          logger.info "'#{property}' with value '#{value}' found"
          dmi[property] = value
        end

        dmiprops = Hash.new
        dmiprops["dmi"] = dmi

        dmiupdate = VM.clone(template, dmiprops)
        if dmiupdate.key? 'machine'
          logger.info "DMI properties added successfully."
        else
          logger.info "Error when adding DMI properties."
        end

        logger.info "Answer from DMI push: #{dmiupdate}"
      else
        logger.info "No DMI properties added"
      end

      # Check if any new NICs are being added
      logger.info "Attempting to detect additional NICs"

      if params[:nichandle].present?
        networks = []

        params[:nichandle].each do |nic|
          networks.push(nic)
          logger.info "- #{nic}"
        end

        options = Hash.new
        options["networks"] = networks

        logger.info "Pushing network adapters..."
        nicupdate = VM.clone(template, options)
        if nicupdate.key? 'machine'
          logger.info "Networks successfully pushed"
        else
          logger.info "Error when pushing networks"
        end

      else
        logger.info "No NIC interfaces added"
      end

      logger.info "Powering on VM"
      poweron = Hash.new
      poweron["state"] = "running"
      switched = VM.clone(template, poweron)

      if switched.key? 'machine'
        if switched["machine"]["state"] == "running"
          logger.info "Machine is running."
        else
          logger.info "Error when powering on machine. State not changed."
        end
      else
        if switched.key? 'error'
          logger.info "Error when powering on machine: #{switched["error"]}"
        else
          logger.info "Unknown error when powering on machine."
        end
      end

      logger.info "Trying to push RDP"

      # Attach master RDP account
      rdpopts = Hash.new
      rdpopts["rdp-username"] = Setting.first.defrdpuser
      rdpopts["rdp-password"] = Setting.first.defrdpsecret
 
      updated = VM.clone(template, rdpopts)

      if updated.key? 'machine'
        logger.info "RDP successfully pushed."
      else
        if updated.key? 'error'
          logger.info "Error when pushing RDP: #{updated["error"]}"
        else
          logger.info "Unknown error when pushing RDP."
        end
      end
      
    logger.info "========================="
    redirect_to root_path, notice: 'Clone was successfully created!'

  rescue StandardError
    redirect_to root_path, notice: "fucked up"

    #rescue StandardError
    #  logger.info "Error occurred"
    #  return redirect_to root_path, notice: error_reason
    #end

    #respond_to do |format|
      #format.js
    #  format.html { redirect_to root_path, notice: 'Clone was successfully created.' }
    #end
  end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_clone
      @clone = Clone.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    #def params
    #  params.fetch({}).permit(:template, :nickname, :utf8, :authenticity_token, :commit, :newsnapshot, :nichandle, :dmiproperty)
    #end
end
