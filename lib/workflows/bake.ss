(set! make-cookbook-request
      (lambda (name)
        (ruby-call-proc "|x| Restaurant::RecipeRequest.new(name: x)" name)))

(define (bake recipe-name)
  (let* ([cookbook (get-service 'cookbook)]
         [cb-request (make-cookbook-request recipe-name)]
         [cb-response (.get_recipe cookbook cb-request)]
         [recipe (.recipe cb-response)]
         [ingredients (vector->list (.ingredients recipe))])
    (ruby-eval "raise 'oops' if ENV['FAIL']")
    (map puts ingredients)))

bake
