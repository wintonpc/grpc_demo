(define-rpc (get-recipe name) [cookbook .get_recipe]
  (ruby-call-proc "|x| Restaurant::RecipeRequest.new(name: x)" name))

(define-rpc (prepare-ingredient name) [sous_chef .prepare]
  (ruby-call-proc "|x| Restaurant::IngredientRequest.new(name: x)" name))

(define (bake recipe-name)
  (puts "Baking a " recipe-name)
  (let* ([recipe (get-recipe recipe-name)]
         [ingredient-names (vector->list (.ingredients recipe))]
         [ingredients (map prepare-ingredient ingredient-names)])
    (puts "ready to mix:")
    (for-each (lambda (i) (puts (.description i))) ingredients)))
