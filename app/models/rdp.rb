class Rdp
  include Mongoid::Document
  belongs_to :VM

  field :rdpuser, type: String
  field :rdpsecret, type: String

  @@apiserver = "http://#{Setting.first.apiserver}:#{Setting.first.apiport}"

  # Sets the state of virtual machine
  def deploy
    request = Http.put("#{@@apiserver}/machine/#{self.VM.identifier}", { "rdp-username" => self.rdpuser, "rdp-password" => self.rdpsecret })
    json = JSON.parse(request.body)

    puts json
    puts "#{Time.now} #{self.VM.identifier}: added RDP user '#{self.rdpuser}' with password '#{self.rdpsecret}'"

    return true
  end

  def blowup
    request = Http.delete("#{@@apiserver}/machine/#{self.VM.identifier}", { "rdp-username" => self.rdpuser, "rdp-password" => self.rdpsecret })
  end
end
