(define (bake recipe-name)
  (define (make-cookbook-request name)
    (ruby-call-proc "|x| Restaurant::RecipeRequest.new(name: x)" name))

  (let* ([cookbook    (get-service 'cookbook)]
         [cb-request  (make-cookbook-request recipe-name)]
         [cb-response (.get_recipe cookbook cb-request)]
         [recipe      (.recipe cb-response)]
         [ingredients (vector->list (.ingredients recipe))])
    (ruby-eval "raise 'oops' if ENV['FAIL']")
    (map puts ingredients)))
