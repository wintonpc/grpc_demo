module Capabilities
  def services
    @services ||= {
        cookbook: Restaurant::Cookbook::Stub.new('localhost:50051', :this_channel_is_insecure)
    }
  end

  def workflows
    @workflows ||= {
        bake: Banzai.define_workflow do
          <<EOD
(set! make-cookbook-request
  (lambda (name)
    (ruby-call-proc "|x| Restaurant::RecipeRequest.new(name: x)" name)))  

(set! bake
  (lambda (recipe-name)
    (begin
      (set! cookbook (get-service 'cookbook))
      (set! cb-request (make-cookbook-request recipe-name))
      (set! recipe (.recipe (.get_recipe cookbook cb-request)))
      (ruby-call-proc "|x| puts x" (.ingredients recipe)))))
EOD
        end
    }
  end

  extend self
end
