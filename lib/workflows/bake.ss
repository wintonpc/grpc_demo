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
         (define (,maker-name ,@attr-names)
           (make-proto ,class-name ,attr-stx))
         (define ,name (list ,class-name ,maker-name (quote ,attr-names)))))))

(define-syntax define-rpc
  (lambda (stx)
    (let* ([proc-name (caadr stx)]
           [formals (cdadr stx)]
           [rpc-info (caddr stx)]
           [service-name (car rpc-info)]
           [method (cadr rpc-info)]
           [request-proto (caddr rpc-info)])
      `(define (,proc-name ,@formals)
         (puts (++ ',proc-name " " ,@formals))
         (let* ([proto ,request-proto]
                [maker (cadr proto)])
           (,method (get-service ',service-name) (maker ,@formals)))))))

(define-proto recipe-request "Restaurant::RecipeRequest" (name))
(define-proto ingredient-request "Restaurant::IngredientRequestt" (name))

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
