module Marshaller
  R = Struct.new(:kind, :type, :data)

  def dump(x)
    Base64.encode64(Zlib::Deflate.deflate(Marshal.dump(Deflater.new.deflate(x))))
  end

  class Deflater
    def seen
      @seen ||= {}
    end

    def deflate(x)
      seen.fetch(x.object_id) do
        seen[x.object_id] = begin
          case x
          when Symbol, NilClass, TrueClass, FalseClass, String, Interop::ServiceShim, Rambda::Transformer
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
          when Rambda::Env
            r = R.new(:env)
            seen[x.object_id] = r
            r.data = [deflate(x.hash), deflate(x.parent), deflate(x.read_only)]
            r
          when Rambda::Closure
            r = R.new(:closure)
            seen[x.object_id] = r
            r.data = [deflate(x.body), deflate(x.env), deflate(x.formals), deflate(x.lambda_exp)]
            r
          when Rambda::AsyncExpr
            r = R.new(:async_expr)
            seen[x.object_id] = r
            r.data = {
                proc: deflate(x.proc),
                env: deflate(x.env),
                done: deflate(x.done),
                value: deflate(x.value),
                exception: deflate(x.exception),
                vm_id: deflate(x.vm_id)
            }
            r
          when Google::Protobuf::RepeatedField
            r = R.new(:pb_repeated_field, pb_item_type(x))
            seen[x.object_id] = r
            r.data = deflate(x.to_a)
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
    inflater = Inflater.new
    state = inflater.inflate(Marshal.load(Zlib::Inflate.inflate(Base64.decode64(x))))
    {state: state, async_exprs: inflater.async_exprs}
  end

  class Inflater
    def seen
      @seen ||= {}
    end

    def async_exprs
      @async_exprs ||= []
    end

    def inflate(x)
      seen.fetch(x.object_id) do
        seen[x.object_id] = begin
          case x
          when Symbol, NilClass, TrueClass, FalseClass, String, Interop::ServiceShim, Rambda::Transformer
            x
          when Array
            r = []
            seen[x.object_id] = r
            x.each do |v|
              r << inflate(v)
            end
            r
          when Hash
            r = {}
            seen[x.object_id] = r
            x.each do |(k, v)|
              r[inflate(k)] = inflate(v)
            end
            r
          when R
            case x.kind
            when :proto
              x.type.decode(x.data)
            when :cons
              r = Rambda::Cons.new
              seen[x.object_id] = r
              dh, dt = x.data
              r.h = inflate(dh)
              r.t = inflate(dt)
              r
            when :sender
              Rambda::Sender.new(inflate(x.data))
            when :env
              r = Rambda::Env.new
              seen[x.object_id] = r
              dhash, dparent, dread_only = x.data
              r.parent = inflate(dparent)
              r.env = inflate(dhash)
              r.read_only = inflate(dread_only)
              r
            when :closure
              r = Rambda::Closure.new
              seen[x.object_id] = r
              dbody, denv, dformals, dlambda_exp = x.data
              r.body = inflate(dbody)
              r.env = inflate(denv)
              r.formals = inflate(dformals)
              r.lambda_exp = inflate(dlambda_exp)
              r
            when :async_expr
              r = Rambda::AsyncExpr.new
              seen[x.object_id] = r
              async_exprs.push(r)
              d = x.data
              r.proc = inflate(d[:proc])
              r.env = inflate(d[:env])
              r.done = inflate(d[:done])
              r.value = inflate(d[:value])
              r.exception = inflate(d[:exception])
              r.vm_id = inflate(d[:vm_id])
              # TODO: rehydrate thread and mutex
              r
            when :primitive
              Rambda::Primitive.new(inflate(x.data))
            when :pb_repeated_field
              Google::Protobuf::RepeatedField.new(x.type, inflate(x.data))
            else
              raise "Not implemented: inflate(#{x.is_a?(R) ? x : x.class})"
            end
          else
            raise "Not implemented: inflate(#{x.is_a?(R) ? x : x.class})"
          end
        end
      end
    end
  end

  extend self
end
