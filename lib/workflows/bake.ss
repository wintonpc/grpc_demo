(define (make-recipe-request name)
  (ruby-call-proc "|x| Restaurant::RecipeRequest.new(name: x)" name))

(define (make-ingredient-request name)
  (ruby-call-proc "|x| Restaurant::IngredientRequest.new(name: x)" name))

(define-rpc (get-recipe name)
  [cookbook .get_recipe]
  (make-recipe-request name))

(define-rpc (prepare-ingredient name)
  [sous_chef .prepare]
  (make-ingredient-request name))

(define (bake recipe-name)
  (pipe recipe-name
        get-recipe
        .ingredients
        (map prepare-ingredient)
        (tap (puts "\nReady to mix:"))
        (for-each (lambda (i) (puts (.description i))))))
