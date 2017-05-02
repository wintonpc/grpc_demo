(define-rpc (get-recipe name)
  [cookbook .get_recipe]
  (ruby-call-proc "|x| Restaurant::RecipeRequest.new(name: x)" name))

(define-rpc (prepare-ingredient name)
  [sous_chef .prepare]
  (ruby-call-proc "|x| Restaurant::IngredientRequest.new(name: x)" name))

(define-rpc (mix ingredients)
  [mixer .mix]
  (ruby-call-proc "|x| Restaurant::MixRequest.new(ingredients: x)" ingredients))

(define (bake recipe-name)
  (puts "\nBaking a " recipe-name)
  (let* ([recipe (get-recipe recipe-name)]
         [ingredient-names (vector->list (.ingredients recipe))]
         [ingredients (map prepare-ingredient ingredient-names)]
         [mixed (mix (list->vector (map .description ingredients)))])
    (puts "We now have " (.description mixed))))
