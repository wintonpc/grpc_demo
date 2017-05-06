;; message mappings
(define-proto (recipe-request name) ; recipe-request has a single attribute 'name'
  ["Restaurant::RecipeRequest"])    ; it maps to this protobuf definition

(define-proto (ingredient-request name)
  ["Restaurant::IngredientRequest"])

(define-proto (mix-request ingredients tool) ; mix-request has attributes 'ingredients'
  ["Restaurant::MixRequest"])                ; and 'tool' (in no particular order)


;; rpc call mappings
(define-rpc (get-recipe name)            ; the 'get-recipe' function takes a parameter 'name'
  [cookbook .get_recipe recipe-request]) ; which it uses to construct a recipe-request
                                         ; to pass to the 'get_recipe' function
                                         ; of the 'cookbook' service

(define-rpc (prepare-ingredient name)
  [sous_chef .prepare ingredient-request])

(define-rpc (mix-ingredients tool ingredients)
  [mixer .mix mix-request])

;; the workflow function
(define (bake recipe-name)
  (pipe recipe-name
        get-recipe
        .ingredients
        (map prepare-ingredient)
        (map .description)
        (tap (puts "Done preparing ingredients. Time to mix."))
        (mix-ingredients "kitchenaid")
        .description
        puts))
