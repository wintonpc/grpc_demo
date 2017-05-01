module Marshaller
  R = Struct.new(:kind, :type, :data)

  def dump(x)
    Base64.encode64(Marshal.dump(Deflater.new.deflate(x)))
  end

  class Deflater
    def seen
      @seen ||= {}
    end

    def deflate(x)
      seen.fetch(x.object_id) do
        seen[x.object_id] = begin
          case x
          when Symbol, NilClass, TrueClass, FalseClass
            x
          when Array
            r = []
            seen[x.object_id] = r
            x.each do |v|
              r << deflate(v)
            end
            r
          when Hash
            r = {}
            seen[x.object_id] = r
            x.each do |(k, v)|
              r[deflate(k)] = deflate(v)
            end
            r
          when Rambda::Cons
            r = R.new(:cons)
            seen[x.object_id] = r
            r.data = [deflate(x.h), deflate(x.t)]
            r
          when Rambda::Sender
            r = R.new(:sender)
            seen[x.object_id] = r
            r.data = deflate(x.method)
            r
          when Rambda::Primitive
            r = R.new(:primitive)
            seen[x.object_id] = r
            r.data = deflate(x.var)
            r
          when Rambda::Transformer
            x
          when Rambda::Env
            r = R.new(:env)
            seen[x.object_id] = r
            r.data = [deflate(x.hash), deflate(x.parent)]
            r
          when Rambda::Closure
            r = R.new(:closure)
            seen[x.object_id] = r
            r.data = [deflate(x.body), deflate(x.env), deflate(x.formals), deflate(x.lambda_exp)]
            r
          when String
            x
          when Interop::ServiceShim
            x
          when Google::Protobuf::RepeatedField
            r = R.new(:pb_repeated_field, pb_item_type(x))
            seen[x.object_id] = r
            r.data = x.to_a
            r
          else
            if x.respond_to?(:to_proto)
              R.new(:proto, x.class, x.to_proto)
            else
              raise "Not implemented: deflate(#{x.class})"
            end
          end
        end
      end
    end

    def pb_item_type(x)
      case x[0]
      when String
        :string
      else
        raise "Not implemented: pb_item_type(#{x[0]})"
      end
    end
  end

  def load(x)

  end

  extend self
end
