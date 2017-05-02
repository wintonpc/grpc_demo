(define-syntax define-rpc
  (lambda (stx)
    (let ([proc-name (caadr stx)]
          [formals (cdadr stx)]
          [service-name (caaddr stx)]
          [method (cadaddr stx)]
          [make-req-bodies (cdddr stx)])
      `(define (,proc-name ,@formals)
         (puts (++ ',proc-name " " ,@formals))
         (,method (get-service ,service-name) ((lambda () ,@make-req-bodies)))))))

(define-rpc (get-recipe name) ['cookbook .get_recipe]
  (ruby-call-proc "|x| Restaurant::RecipeRequest.new(name: x)" name))

(define-rpc (prepare-ingredient name) ['sous_chef .prepare]
  (ruby-call-proc "|x| Restaurant::IngredientRequest.new(name: x)" name))

;; (define (call-service service-name rpc-method desc request)
;;   (puts desc)
;;   (rpc-method (get-service service-name) request))

;; ;; (define (get-recipe name)
;; ;;   (.recipe
;; ;;    (call-service 'cookbook .get_recipe "Getting recipe"
;; ;;                  )))

;; (define (prepare-ingredient name)
;;   (.ingredient
;;    (call-service 'sous_chef .prepare (++ "Preparing " name)
;;                  (ruby-call-proc "|x| Restaurant::IngredientRequest.new(name: x)" name))))

(define (bake recipe-name)
  (puts "Baking a " recipe-name)
  (let* ([recipe (.recipe (get-recipe recipe-name))]
         [ingredient-names (vector->list (.ingredients recipe))]
         [ingredients (map (compose .ingredient prepare-ingredient) ingredient-names)])
    (puts "ready to mix:")
    (for-each (lambda (i) (puts (.description i))) ingredients)))
