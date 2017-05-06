(define (make-proto class-name attrs)
  (ruby-call-proc (++ "|attrs| " class-name ".new(attrs)") attrs))

(define-syntax define-proto
  (lambda (stx)
    (let* ([name (cadr stx)]
           [class-name (caddr stx)]
           [attr-names (cadddr stx)]
           [maker-name (string->symbol (++ "make-" name))]
           [attr-stx (cons 'make-map (flatmap (lambda (n) (list `(quote ,n) n)) attr-names))])
      `(begin
         (define ,name (list ,class-name (quote ,attr-names)))
         (define (,maker-name ,@attr-names)
           (make-proto ,class-name ,attr-stx))))))

(define-syntax define-rpc
  (lambda (stx)
    (let* ([proc-name (caadr stx)]
           [formals (cdadr stx)]
           [rpc-info (caddr stx)]
           [service-name (car rpc-info)]
           [method (cadr rpc-info)]
           [request-proto (caddr rpc-info)]
           [make-req-bodies (cdddr stx)])
      `(define (,proc-name ,@formals)
         (puts (++ ',proc-name " " ,@formals))
         (,method (get-service ',service-name) ((lambda () ,@make-req-bodies)))))))

(define-proto recipe-request "Restaurant::RecipeRequest" (name))
(define-proto ingredient-request "Restaurant::IngredientRequest" (name))

(define-rpc (get-recipe name)
  [cookbook .get_recipe recipe-request]
  (make-recipe-request name))

(define-rpc (prepare-ingredient name)
  [sous_chef .prepare ingredient-request]
  (make-ingredient-request name))

(define (bake recipe-name)
  (pipe recipe-name
        get-recipe
        .ingredients
        (map prepare-ingredient)
        (tap (puts "\nReady to mix:"))
        (for-each (lambda (i) (puts (.description i))))))
