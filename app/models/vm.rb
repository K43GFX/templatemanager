# Model to manipulate with VMs via i-tee-virtualbox API
class VM

  require "date"
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic #support for dynamic (API) fields

  after_find :get_vm_data

  has_many :activities
  has_many :snapshots
  has_many :rdps
  
  field :identifier, type: String
  field :last_updated, type: DateTime
  field :purpose, type: String
  field :error, type: Boolean


  @@apiserver = "http://#{Setting.first.apiserver}:#{Setting.first.apiport}"

  # Sets the state of virtual machine
  def set_state(state)
    request = Http.put("#{@@apiserver}/machine/#{self.identifier}", { "state" => state })
    logger.info "#{Time.now} #{self.identifier}: setting state of VM to #{state}"

  end

  # Find all initialized machines from I-Tee-Virtualbox API. 
  def self.discover

  	raw_data = Http.get("#{@@apiserver}/machine/", {})
  	json = JSON.parse(raw_data.body, object_class: OpenStruct)

  	json.each do |vm|

      unless self.where(identifier: vm["id"]).exists?
        if vm['id'].include? "template"
          purpose = "template"
        else
          purpose = "basic"
        end

        self.create(identifier: vm["id"], purpose: purpose)

        # Add default RDP user
        # vm = self.find_by(identifier: vm['id'])
        # rdp = vm.rdps.new
        # rdp.rdpuser = Setting.first.defrdpuser
        # rdp.rdpsecret = Setting.first.defrdpsecret

        # deployed = rdp.deploy

        # if deployed
        #   rdp.save
        #   rdpstatus = "Default RDP account added."
        # else
        #   rdpstatus = "Default RDP account init failed."
        # end

        rdpstatus = "RDP not deployed"

        puts "#{vm["id"]}: added to database. #{rdpstatus}"
      else
        puts "#{vm["id"]}: already in system."
      end
  	end

  end

  # Reload / Get virtual machine's attributes
  def get_vm_data
  	raw_data = Http.get("#{@@apiserver}/machine/#{self.identifier}", {})
  	json = JSON.parse(raw_data.body)

  	if json.key? "machine"

  		vm = json["machine"]

  		self["state"] = vm["state"]

  		if vm.key? "rdp-port"
  			self["vrdeport"] = vm["rdp-port"]
      else
        self["vrdeport"] = nil
  		end

  		if vm.key? "snapshot"
  			self["snap"] = vm["snapshot"]
      else
        self["snap"] = nil
  		end

      if vm.key? "qaversion"
        self["qa"] = vm["qaversion"]
      #else
        #self["qa"] = nil
      end

      if vm.key? "ipv4"
        self["ipv4"] = vm["ipv4"]
      else
        self["ipv4"] = nil
      end

      self.last_updated = Time.now
      self.error = false
  	else
  		self.error = true
      self['state'] = nil
      self['snap'] = nil
      self['vrdeport'] = nil
      self['snapshot'] = nil
      self['qaversion'] = nil
      self['ipv4'] = nil
  	end

  end

  def blowup
    request = Http.delete("#{@@apiserver}/machine/#{self.identifier}", {})
    response = JSON.parse(request.body)

    unless response.key? 'error'
      return true
    else
      return false
      @error = response["error"]
    end
  end

  def self.clone(newname, options)
    request = Http.put("#{@@apiserver}/machine/#{newname}", options)
    response = JSON.parse(request.body)
    return response
  end
end
