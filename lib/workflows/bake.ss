(define (make-proto class-name attrs)
  (ruby-call-proc (++ "|attrs| " class-name ".new(attrs)") attrs))

(define (make-recipe-request name)
  (make-proto "Restaurant::RecipeRequest" {name name}))

(define (make-ingredient-request name)
  (make-proto "Restaurant::IngredientRequest" {name name}))

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
