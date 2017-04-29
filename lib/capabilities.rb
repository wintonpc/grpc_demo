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
      (set! cb-response (.get_recipe cookbook cb-request))
      (set! recipe (.recipe cb-response))
      (set! ingredients (vector->list (.ingredients recipe)))
      (ruby-eval "raise 'oops' if ENV['FAIL']")
      (map ingredients (lambda (x) (ruby-call-proc "|x| puts x" x))))))
EOD
        end
    }
  end

  extend self
end
