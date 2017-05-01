module Interop
  ServiceShim = Struct.new(:name)
  class ServiceShim
    def method_missing(meth, *args)
      Capabilities.services[self.name].send(meth, *args)
    end
  end

  def self.make_serializable(pb_mod)
    msg_types =
        pb_mod.constants
            .map { |c| pb_mod.const_get(c) }
            .select { |x| x.is_a?(Class) && x.ancestors.include?(Google::Protobuf::MessageExts)}
    msg_types.each do |m|
      m.instance_exec do
        define_method(:_dump) do |_level|
          puts 'marshaling with _dump'
          result = Marshal.dump([self.class.to_s, self.to_proto])
          puts 'done marshaling with _dump'
          result
        end
      end
      m.define_singleton_method(:_load) do |data|
        klass, proto = Marshal.load(data)
        klass.decode(proto)
      end
    end
  end
end
