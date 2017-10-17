class SnapshotsController < ApplicationController
  before_action :set_vm, :set_author

  # Action to process JS to open Snapshot modal
  def new_snapshot
    respond_to do |format|
      format.js
    end
  end

  def create
  	#logger.info "Attempting to create snapshot 'SNAPSHOT' for machine #{@machine.identifier}, which is created by #{current_user.email}"
    if @machine.state == "running"
      @machine.set_state('poweroff')
    end
    
    snapshot = @machine.snapshots.snapshot.new
    snapshot.author = current_user.email
    snapshot.date = Time.now
    snapshot.nickname = params[:name]
    snapshot.created_from = @machine.try(:snap)

    if snapshot.valid?

      if @machine.state == "running"
        @machine.set_state('poweroff')
      end

      createsnapshot = snapshot.make
      if createsnapshot
        snapshot.uuid = createsnapshot # returned by Snapshot.make()
        logger.info "#{@machine.identifier}: new snapshot '#{snapshot.nickname}' with UUID '#{createsnapshot}'"
        snapshot.save!
        @alertmessage = "Snapshot created successfully!"
      else
        @alertmessage = "Could not create snapshot: Hypervisor error"
      end
    else
      @alertmessage = "Could not create snapshot: name already exists"
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy

    snapshots = params[:snapshot_ids]
    unless snapshots.blank?

      if @machine.state == "running"
        @machine.set_state('poweroff')
      end
      
      snapshots.each do |snap|
        
        snapshot = Snapshot.find(snap)

        unless @machine.snapshots.where(created_from: snapshot.nickname).any?
          logger.info "#{snapshot.nickname}: not a parent snapshot [DELETE]"
          if @machine.state == "running"
            @machine.set_state('poweroff')
          end
           if snapshot.blowup?
            logger.info "#{@machine.identifier}: snapshot '#{snapshot.nickname}' deleted"
            else
            logger.info "#{@machine.identifier}: error when deleting snapshot '#{snapshot.nickname}'"
           end
          #parent = @machine.snapshots.where(created_from: snapshot.nickname)
          #logger.info "Parent of '#{snapshot.nickname}': '#{parent.nickname}' [KEEP]"
        else
          logger.info "#{snapshot.nickname}: parent of another snapshot [KEEP]"
          #logger.info "Parent of '#{snapshot.nickname}': none in tplmgr [DELETE]"
        end

      end
      @alertmessage = 'Attempted to delete snapshots. Refresh page.'
    else
      logger.info "No snapshots chosen to be deleted."
      @alertmessage = 'No snapshots chosen to be deleted.'
    end

    respond_to do |format|
      format.js
    end
  end

  private

  def no_functionality
    respond_to do |format|
      format.js
    end
  end

  def show
  end

  def set_vm
  	@machine = VM.find(params[:vm])
  end

  def set_author
  	@author = current_user
  end
end
