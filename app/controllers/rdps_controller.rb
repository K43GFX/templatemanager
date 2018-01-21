class RdpsController < ApplicationController
  before_action :set_vm
  def index
  end

  def show
    if @machine.vrdeport.present?
      auth = Rdp.find(params['account'])
      host = "i-dev.itcollege.ee:#{@machine.vrdeport}"

      @command = "rdesktop -u #{auth.rdpuser} -p#{auth.rdpsecret} #{host}"

      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        format.js { render :template => "rdps/rdpdown" }
      end
    end
  end

  def new_rdp
    respond_to do |format|
      format.js
    end
  end

  def create
  	user = params['rdpuser']
  	secret = params['rdpsecret']

  	authentication = @machine.rdps.new
  	authentication.rdpuser = user
  	authentication.rdpsecret = secret

  	if authentication.valid?
  		logger.info "#{@machine.identifier}: adding RDP user '#{user}' with secret '#{secret}'"
  		deployed = authentication.deploy
  		if deployed
        @alertmessage = "RDP account added!"
        authentication.save
      else
        @alertmessage = "Error when adding RDP account"
        logger.info "#{@machine.identifier}: error when adding RDP user '#{user}' with secret '#{secret}'"
        authentication.save
  		end
  	end

    respond_to do |format|
      format.js
    end
  end

private
  def set_vm
  	@machine = VM.find(params[:vm])
  end
end
