(define-proto (recipe-request name)
  ["Restaurant::RecipeRequest"])

(define-proto (ingredient-request name)
  ["Restaurant::IngredientRequest"])

(define-rpc (get-recipe name)
  [cookbook .get_recipe recipe-request])

(define-rpc (prepare-ingredient name)
  [sous_chef .prepare ingredient-request])

(define (bake recipe-name)
  (pipe recipe-name
        get-recipe
        .ingredients
        (map prepare-ingredient)
        (tap (puts "\nReady to mix:"))
        (for-each (lambda (i) (puts (.description i))))))
