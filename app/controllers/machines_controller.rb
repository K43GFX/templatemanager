class MachinesController < ApplicationController
  before_action :set_machine, only: [:show, :edit, :update, :destroy]
  before_action :verify_settings, :authenticate_user!, :verify_api
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
  end

  # GET /machines/new
  def new
    @machine = VM.new
  end

  # GET /machines/1/edit
  def edit
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
    puts "Hey there, I WAS REACHED!"

    @machine = VM.find_by(identifier: params[:identifier])
    puts @machine.identifier

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

    #logger.info "#{vm.identifier}: updating machine's information"
    #vm.get_vm_data

    vm.activities.create(action: "State changed to: #{newstate}", date: Time.now, initiated_by: current_user.email )

    @machine = VM.find(params[:id])

    respond_to do |format|
      format.js
    end

  end

  # DELETE /machines/1
  # DELETE /machines/1.json
  def destroy
    @machine.destroy
    respond_to do |format|
      format.html { redirect_to machines_url, notice: 'Machine was successfully destroyed.' }
      format.json { head :no_content }
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

      begin

        host = Setting.first.apiserver
        port = Setting.first.apiport

        uri = URI.parse("http://#{host}:#{port}")

        Net::HTTP.start(host, port) do |http|
          http.read_timeout = 2
          request = Net::HTTP::Get.new uri
          response = http.request request # Net::HTTPResponse object
          if valid_json?(response.body)
            # ok
          else
            raise StandardError
          end
        end
      rescue StandardError
        logger.info "API server not reachable"
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
