# Model to initialize setup process
class Snapshot
  include Mongoid::Document

  belongs_to :VM
  
  @@apiserver = "http://#{Setting.first.apiserver}:#{Setting.first.apiport}"

  field :nickname, type: String
  field :uuid, type: String
  field :date, type: DateTime
  field :author, type: String
  field :created_from, type: String

  validates_uniqueness_of :nickname, scope: :VM

  def make
    puts "#{self.VM.identifier}: creating snapshot #{self.nickname}"
  	request = Http.post("#{@@apiserver}/machine/#{self.VM.identifier}/snapshot/#{self.nickname}", {})

    json = JSON.parse(request.body)

    if json.any?
      if json.key? "snapshot-uuid"
        @uuid = json["snapshot-uuid"]
        @uuid
      else
        raise StandardError
      end
    else
      raise StandardError
    end
    #unless request.body == "{}"
    #	raise StandardError
    #else
    #	request.body
    #end

    #puts request.body 

  end

  def blowup?
    puts "#{self.VM.identifier}: deleting snapshot #{self.nickname}"
  	request = Http.delete("#{@@apiserver}/machine/#{self.VM.identifier}/snapshot/#{self.nickname}", {})
    json = JSON.parse(request.body)

    if json.any?
      puts json
      if json.key? 'status'
        self.destroy
        return true
      else
        self.destroy
        return false
      end
    end

  end

end