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


  @@apiserver = "http://#{Setting.first.apiserver}:#{Setting.first.apiport}"

  # Sets the state of virtual machine
  def set_state(state)
    request = Http.put("#{@@apiserver}/machine/#{self.identifier}", { "state" => state })
    logger.info "#{Time.now} #{self.identifier}: setting state of VM to #{state}"

  end

  # Find all initialized machines from I-Tee-Virtualbox API. 
  def self.discover

  	raw_data = Http.get("#{@@apiserver}/machine/", {})
  	json = JSON.parse(raw_data.body)

  	json.each do |vm|

      unless self.where(identifier: vm["id"]).exists?
        if vm['id'].include? "template"
          purpose = "template"
        else
          purpose = "basic"
        end

        self.create(identifier: vm["id"], purpose: purpose)
        puts "#{vm["id"]}: added to database"
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
  		end

  		if vm.key? "snapshot"
  			self["snap"] = vm["snapshot"]
  		end

      if vm.key? "qaversion"
        self["qa"] = vm["qaversion"]
      end

      if vm.key? "ipv4"
        self["ipv4"] = vm["ipv4"]
      end

      self.last_updated = Time.now
  	else
  		self["error"] = json["error"]
  	end

  end
end
