(define-rpc (get-recipe name)
  [cookbook .get_recipe]
  (ruby-call-proc "|x| Restaurant::RecipeRequest.new(name: x)" name))

(define-rpc (prepare-ingredient name)
  [sous_chef .prepare]
  (ruby-call-proc "|x| Restaurant::IngredientRequest.new(name: x)" name))

(define (bake recipe-name)
  (pipe recipe-name
        get-recipe
        .ingredients
        (map prepare-ingredient)
        (tap (puts "\nReady to mix:"))
        (for-each (lambda (i) (puts (.description i))))))
