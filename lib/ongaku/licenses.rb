
module Ongaku

  class License
    def License.register( name )
      @@licenses ||= []
      @@licenses.push(name)
    end

    def License.list()
      # Clone the list to prevent modifications thru return value
      @@licenses.map {|i| i }
    end
  end

  License.register("Unknown")
  License.register("Commercial")

  # Creative Commons Licenses
  License.register("CC BY")
  License.register("CC BY-ND")
  License.register("CC BY-NC-SA")
  License.register("CC BY-SA")
  License.register("CC BY-NC")
  License.register("CC BY-NC-ND")
end


