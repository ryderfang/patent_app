require 'rubygems'
require 'net/ldap'

class UserAuth
  HOST = "ldap1-pek2.eng.vmware.com"
  PORT = 636
  BASE = "dc=vmware,dc=com"

  def initialize
  end

  def self.authenticate(user, pass)
    return nil if user.empty? or pass.empty?

    userName = ",ou=people,dc=vmware,dc=com"
    conn = Net::LDAP.new :host => HOST,
                     :port => PORT,
                     :base => BASE,
                     :encryption => :simple_tls

    userName = "uid=#{user}" + userName
    conn.auth userName, pass

    if conn.bind
      filter = Net::LDAP::Filter.eq("uid", "#{user}")
      conn.search(:base => BASE, :filter => filter) do |entry|
        #puts entry.cn
        return entry.cn
      end
    else
      return nil
    end

    rescue Net::LDAP::LdapError => e
      return nil
  end
end