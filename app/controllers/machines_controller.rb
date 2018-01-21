class MachinesController < ApplicationController
  before_action :set_machine, only: [:show, :edit, :update, :destroy]
  before_action :verify_settings, :authenticate_user!
  before_action :verify_api, except: [:no_functionality, :refresh_dashboard_vm, :refresh_vm, :destroyghost]
  # GET /machines
  # GET /machines.json
  def index
    VM.discover

    #@machines = Machine.where(active: true)
    @machines = VM.all
    #puts @machines
  end

  # GET /machines/1
  # GET /machines/1.json
  def show
    @snapshots = Snapshot.discover(@machine.identifier)
  end

  # GET /machines/new
  def new
    @machine = VM.new
  end

  # GET /machines/1/edit
  def edit
  end

  def no_functionality
    respond_to do |format|
      format.js
    end
  end

  # POST /machines
  # POST /machines.json
  def create
    @machine = VM.new(machine_params)

    respond_to do |format|
      if @machine.save
        format.html { redirect_to @machine, notice: 'Machine was successfully created.' }
        format.json { render :show, status: :created, location: @machine }
      else
        format.html { render :new }
        format.json { render json: @machine.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /machines/1
  # PATCH/PUT /machines/1.json
  def update
    respond_to do |format|
      format.html
    end
  end

  def refresh_dashboard_vm
    @machine = VM.find_by(identifier: params[:identifier])

    respond_to do |format|
      format.js
    end
  end

  def refresh_vm
    @machine = VM.find_by(identifier: params[:identifier])
    machine = VM.find_by(identifier: params[:identifier])

    respond_to do |format|
      format.js
    end
  end

  # Attempts to set the state for Virtual Machine
  def setstate
    vm = VM.find(params[:id])

    if vm.state == "running"
      newstate = "poweroff"
    else
      newstate = "running"
    end

    # Change machine's state
    logger.info "#{vm.identifier}: changing VM state to #{newstate}"
    vm.set_state(newstate)

    vm.activities.create(action: "State changed to: #{newstate}", date: Time.now, initiated_by: current_user.email )

    @machine = VM.find(params[:id])

    respond_to do |format|
      format.js
    end

  end

  # DELETE /machines/1
  # DELETE /machines/1.json
  def destroy
    vm = VM.find(params[:vm])

    destroyed = vm.blowup

    respond_to do |format|
      if destroyed
        if vm.destroy
          format.html { redirect_to root_path, notice: 'Machine was successfully destroyed' }
        else
          format.html { redirect_to root_path, notice: 'Could not destroy machine' }
        end
      else
        format.html { redirect_to root_path, notice: "Could not destroy machine"}
      end
    end
  end

  def destroyghost
    vm = VM.find(params[:vm])

    respond_to do |format|
      if vm.destroy
        format.html { redirect_to root_path, notice: "Machine removed from Dashboard" }
      else
        format.html { redirect_to root_path, notice: "Couldn't remove machine from Dashboard" }
      end
    end
  end

  private

    def verify_settings
      if Setting.first.nil?
        redirect_to setup_path
      end
    end
    # Tests the availiability of API before showing content
    def verify_api

    # Skip the test if developer settings are activated
    if Setting.first.developermode?
      logger.info "Developer settings activated, bypassing API check"
    else
        logger.info "Testing backend..."
        host = Setting.first.apiserver
        port = Setting.first.apiport

        begin
          Socket.tcp(host, port, connect_timeout: 2) {}
        rescue StandardError
          redirect_to error_api_not_found_path
        end

    end #devmode

    end #def

    # Use callbacks to share common setup or constraints between actions.
    def set_machine
      @machine = VM.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def machine_params
      params.fetch(:machine, {})
    end

    # Validate JSON response from given string
    def valid_json?(json)
      begin
        JSON.parse(json)
        return true
      rescue JSON::ParserError => e
        return false
      end
    end

end
