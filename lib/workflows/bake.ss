(define (get-recipe name)
  (puts "Getting recipe")
  (let* ([cookbook (get-service 'cookbook)]
         [request  (ruby-call-proc "|x| Restaurant::RecipeRequest.new(name: x)" name)]
         [response (.get_recipe cookbook request)])
    (.recipe response)))

(define (prepare-ingredient name)
  (puts "Preparing " name)
  (let* ([sous-chef (get-service 'sous_chef)]
         [request  (ruby-call-proc "|x| Restaurant::IngredientRequest.new(name: x)" name)]
         [response (.prepare sous-chef request)])
    (.ingredient response)))

(define (bake recipe-name)
  (puts "Baking a " recipe-name)
  (let* ([recipe (get-recipe recipe-name)]
         [ingredient-names (vector->list (.ingredients recipe))]
         [ingredients (map prepare-ingredient ingredient-names)])
    (puts "ready to mix:")
    (for-each (lambda (i) (puts (.description i))) ingredients)))
