class SnapshotsController < ApplicationController
  before_action :set_vm, :set_author

  # Action to process JS to open Snapshot modal
  def new_snapshot
    respond_to do |format|
      format.js
    end
  end

  def create
    if @machine.state == "running"
      @machine.set_state('poweroff')
    end
    
    snapshotname = params['name']
    vm_identifier = @machine.identifier

    created = Snapshot.make(vm_identifier, snapshotname)

    if created
      logger.info created
      @alertmessage = "Snapshot was created"
    else
      logger.info created
      @alertmessage = "Error when creating snapshot"
    end

    @snapshots = Snapshot.discover(@machine.identifier)
    @vmid = @machine.identifier
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
    	 destroyed = Snapshot.destroy(@machine.identifier, snap)
        if destroyed
          @alertmessage = "Snapshot is deleted!"
        else
          @alertmessage = "Error when deleting snapshot!"
        end

      end

    else
      @alertmessage = "No snapshots are chosen to be deleted!"  
    end

    @snapshots = Snapshot.discover(@machine.identifier)
    @vmid = @machine.identifier
    
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
    @snapshots = Snapshot.discover(@machine.identifier)
  end

  def set_vm
  	@machine = VM.find(params[:vm])
  end

  def set_author
  	@author = current_user
  end
end
