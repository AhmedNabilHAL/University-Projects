;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname space-invaders-SOL) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders

;; ====================================
;; Constants:

(define WIDTH  300)
(define HEIGHT 500)

(define INVADER-X-SPEED 3)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED 3)
(define TANK-SPEED 5)
(define MISSILE-SPEED 10)

(define HIT-RANGE 10)

(define INVADE-RATE 10)

(define BACKGROUND (empty-scene WIDTH HEIGHT))

(define INVADER
  (overlay/xy (ellipse 10 15 "outline" "blue")              ;cockpit cover
              -5 6
              (ellipse 20 10 "solid"   "blue")))            ;saucer

(define TANK
  (overlay/xy (overlay (ellipse 28 8 "solid" "black")       ;tread center
                       (ellipse 30 10 "solid" "green"))     ;tread outline
              5 -14
              (above (rectangle 5 10 "solid" "black")       ;gun
                     (rectangle 20 10 "solid" "black"))))   ;main body

(define TANK-HEIGHT/2 (/ (image-height TANK) 2))
(define TANK-WIDTH/2 (/ (image-width TANK) 2))
(define INVADER-WIDTH/2 (/ (image-width INVADER) 2))
(define MISSILE (ellipse 5 15 "solid" "red"))

(define MTS (empty-scene WIDTH HEIGHT))
(define BLANK empty-image)

;; ====================================
;; Data Definitions:

(define-struct game (invaders missiles tank))
;; Game is (make-game  (listof Invader) (listof Missile) Tank)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position

;; Game constants defined below Missile data definition

#;
(define (fn-for-game g)
  (... (fn-for-loinvader (game-invaders g))
       (fn-for-lom (game-missiles g))
       (fn-for-tank (game-tank g))))



(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1, doesn't move if 0
(define T0 (make-tank (/ WIDTH 2) 1))   ;center going right
(define T1 (make-tank 50 1))            ;going right
(define T2 (make-tank 50 -1))           ;going left

#;
(define (fn-for-tank t)
  (... (tank-x t) (tank-dir t)))



(define-struct invader (x y dx))
;; Invader is (make-invader Number Number Number)
;; interp. the invader is at (x, y) in screen coordinates
;;         the invader along x by dx pixels per clock tick

(define I1 (make-invader 150 100 12))           ;not landed, moving right
(define I2 (make-invader 150 HEIGHT -10))       ;exactly landed, moving left
(define I3 (make-invader 150 (+ HEIGHT 10) 10)) ;> landed, moving right


#;
(define (fn-for-invader invader)
  (... (invader-x invader) (invader-y invader) (invader-dx invader)))

;; ListOfInvaders is one of:
;;  - empty
;;  - (cons invader ListOfInvaders)

(define LOI empty)
(define LOI1 (cons I1 empty))
(define LOI2 (cons I1 (cons I2 empty)))
(define LOI3 (cons I1 (cons I2 (cons I3 empty))))

#;
(define (fn-for-loi loi)
  (cond [(empty? loi) (...)]
        [else
         (... (fn-for-invader (first loi)) (fn-for-loi (rest loi)))]))

(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates

(define M1 (make-missile 150 300))                       ;not hit U1
(define M2 (make-missile (invader-x I1) (+ (invader-y I1) 10)))  ;exactly hit U1
(define M3 (make-missile (invader-x I1) (+ (invader-y I1)  5)))  ;> hit U1

#;
(define (fn-for-missile m)
  (... (missile-x m) (missile-y m)))

;; ListOfMissiles is one of:
;;  - empty
;;  - (cons Missile ListOfMissile)

(define LOM empty)
(define LOM1 (cons M1 empty))
(define LOM2 (cons M1 (cons M2 empty)))
(define LOM3 (cons M1 (cons M2 (cons M3 empty))))
#;
(define (fn-for-lom lom)
  (cond [(empty? lom) (...)]
        [else
         (... (fn-for-missile (first lom)) (fn-for-lom (rest lom)))]))


(define G0 (make-game empty empty T0))
(define G1 (make-game empty empty T1))
(define G2 (make-game (list I1) (list M1) T1))
(define G3 (make-game (list I1 I2) (list M1 M2) T1))



;; ====================================
;; Functions:

;; Game -> Game
;; start the world with (main (make-game empty empty (make-tank (/ WIDTH 2) 0)))
;; 
(define (main g)
  (big-bang g                           ; g
    (on-tick   advance-game)            ; g -> g
    (to-draw   render)          ; g -> Image
    (stop-when istouched?)      ; g -> Boolean
    (on-key    key-handler)     ; g KeyEvent -> g
    (on-release rel-handler)))     ; g keyEvent -> g

;; g -> g
;; Moves the tank left or right depending on its dir
;; moves the invaders down and the (right/left) depending of its dir and a new invader is added according to invader rate
;; and if it collides with a wall
;; moves the shots up

(check-random (advance-game (make-game empty empty (make-tank (/ WIDTH 2) 1)))
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? empty))
                             (cons (make-invader (random WIDTH) 0 12) empty)
                             empty) empty (make-tank (+ (/ WIDTH 2) TANK-SPEED) 1)))

(check-random (advance-game (make-game empty empty (make-tank (/ WIDTH 2) 0)))
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? empty))
                             (cons (make-invader (random WIDTH) 0 12) empty)
                             empty) empty (make-tank (/ WIDTH 2) 0)))

(check-random (advance-game (make-game empty empty (make-tank (/ WIDTH 2) -1)))
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? empty))
                             (cons (make-invader (random WIDTH) 0 12) empty)
                             empty) empty (make-tank (- (/ WIDTH 2) TANK-SPEED) -1)))

(check-random (advance-game (make-game (list (make-invader 150 100 12) ) (list (make-missile 150 300) ) (make-tank 50 1)))
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? (list (make-invader 150 100 12) )))
                             (cons (make-invader (random WIDTH) 0 12) (list (make-invader (+ 150 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12) ))
                             (list (make-invader (+ 150 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12) )) (list (make-missile 150 (- 300 MISSILE-SPEED)) )
                                                                                                        (make-tank (+ 50 TANK-SPEED) 1)))

(check-random (advance-game (make-game (list (make-invader 150 100 12) (make-invader 150 HEIGHT -10) )
                                       (list (make-missile 150 300) (make-missile (invader-x I1) (+ (invader-y I1) 15)) )
                                       (make-tank 50 1)))
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? (list (make-invader 150 100 12) (make-invader 150 HEIGHT -10) )))
                             (cons (make-invader (random WIDTH) 0 12) (list (make-invader (+ 150 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12) (make-invader (- 150 INVADER-X-SPEED) (+ HEIGHT INVADER-Y-SPEED) -10) ))
                             (list (make-invader (+ 150 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12) (make-invader (- 150 INVADER-X-SPEED) (+ HEIGHT INVADER-Y-SPEED) -10) ))
                         (list (make-missile 150 (- 300 MISSILE-SPEED)) (make-missile (invader-x I1) (- (+ (invader-y I1) 15) MISSILE-SPEED)) )
                         (make-tank (+ 50 TANK-SPEED) 1)))

(check-random (advance-game G3)
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? (game-invaders G3)))
                             (cons (make-invader (random WIDTH) 0 12) (list (make-invader (- 150 INVADER-X-SPEED) (+ HEIGHT INVADER-Y-SPEED) -10) ))
                             (list (make-invader (- 150 INVADER-X-SPEED) (+ HEIGHT INVADER-Y-SPEED) -10) ))
                         (list (make-missile 150 (- 300 MISSILE-SPEED)) )
                         (make-tank (+ 50 TANK-SPEED) 1)))

(check-random (advance-game (make-game (list (make-invader 150 50 12) (make-invader 150 100 -10) )
                                       (list (make-missile 150 300) (make-missile 150 (+ 100 5)) )
                                       (make-tank 50 1)))
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? (list (make-invader 150 50 12) (make-invader 150 100 -10) )))
                             (cons (make-invader (random WIDTH) 0 12) (list (make-invader (+ 150 INVADER-X-SPEED) (+ 50 INVADER-Y-SPEED) 12) ))
                             (list (make-invader (+ 150 INVADER-X-SPEED) (+ 50 INVADER-Y-SPEED) 12) ))
                         (list (make-missile 150 (- 300 MISSILE-SPEED)) )
                         (make-tank (+ 50 TANK-SPEED) 1)))

(check-random (advance-game (make-game (list (make-invader 150 50 12) (make-invader 150 100 -10) )
                                       (list (make-missile 150 300) (make-missile 150 (- 100 5)) )
                                       (make-tank 50 1)))
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? (list (make-invader 150 50 12) (make-invader 150 100 -10) )))
                             (cons (make-invader (random WIDTH) 0 12) (list (make-invader (+ 150 INVADER-X-SPEED) (+ 50 INVADER-Y-SPEED) 12) ))
                             (list (make-invader (+ 150 INVADER-X-SPEED) (+ 50 INVADER-Y-SPEED) 12) ))
                         (list (make-missile 150 (- 300 MISSILE-SPEED)) )
                         (make-tank (+ 50 TANK-SPEED) 1)))

(check-random (advance-game (make-game (list (make-invader 150 50 12) (make-invader 150 100 -10) )
                                       (list (make-missile 150 300) (make-missile 150 (+ 100 HIT-RANGE)) )
                                       (make-tank 50 1)))
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? (list (make-invader 150 50 12) (make-invader 150 100 -10) )))
                             (cons (make-invader (random WIDTH) 0 12) (list (make-invader (+ 150 INVADER-X-SPEED) (+ 50 INVADER-Y-SPEED) 12) ))
                             (list (make-invader (+ 150 INVADER-X-SPEED) (+ 50 INVADER-Y-SPEED) 12) ))
                         (list (make-missile 150 (- 300 MISSILE-SPEED)) )
                         (make-tank (+ 50 TANK-SPEED) 1)))

(check-random (advance-game (make-game (list (make-invader 150 50 12) (make-invader 150 100 -10) )
                                       (list (make-missile 150 300) (make-missile 150 (- 100 HIT-RANGE)) )
                                       (make-tank 50 1)))
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? (list (make-invader 150 50 12) (make-invader 150 100 -10) )))
                             (cons (make-invader (random WIDTH) 0 12) (list (make-invader (+ 150 INVADER-X-SPEED) (+ 50 INVADER-Y-SPEED) 12) ))
                             (list (make-invader (+ 150 INVADER-X-SPEED) (+ 50 INVADER-Y-SPEED) 12) ))
                         (list (make-missile 150 (- 300 MISSILE-SPEED)) )
                         (make-tank (+ 50 TANK-SPEED) 1)))

(check-random (advance-game (make-game (list (make-invader 150 100 12) (make-invader 150 HEIGHT -10) )
                                       (list (make-missile 150 300) (make-missile 150 100) )
                                       (make-tank 50 1)))
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? (list (make-invader 150 100 12) (make-invader 150 HEIGHT -10) )))
                             (cons (make-invader (random WIDTH) 0 12) (list (make-invader (- 150 INVADER-X-SPEED) (+ HEIGHT INVADER-Y-SPEED) -10) ))
                             (list (make-invader (- 150 INVADER-X-SPEED) (+ HEIGHT INVADER-Y-SPEED) -10) ))
                         (list (make-missile 150 (- 300 MISSILE-SPEED)) )
                         (make-tank (+ 50 TANK-SPEED) 1)))

(check-random (advance-game (make-game (list (make-invader 150 100 12) (make-invader 150 HEIGHT -10) )
                                       (list (make-missile 150 300) (make-missile 150 99 ) )
                                       (make-tank 50 1)))
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? (list (make-invader 150 100 12) (make-invader 150 HEIGHT -10) )))
                             (cons (make-invader (random WIDTH) 0 12) (list (make-invader (- 150 INVADER-X-SPEED) (+ HEIGHT INVADER-Y-SPEED) -10) ))
                             (list (make-invader (- 150 INVADER-X-SPEED) (+ HEIGHT INVADER-Y-SPEED) -10) ))
                         (list (make-missile 150 (- 300 MISSILE-SPEED)) )
                         (make-tank (+ 50 TANK-SPEED) 1)))

(check-random (advance-game (make-game (list (make-invader (+ WIDTH 1) 100 12) ) (list (make-missile 150 300) ) (make-tank 50 1)))
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? (list (make-invader (+ WIDTH 1) 100 12) )))
                             (cons (make-invader (random WIDTH) 0 12) (list (make-invader (- (+ WIDTH 1) INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) -12) ))
                             (list (make-invader (- (+ WIDTH 1) INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) -12) )) (list (make-missile 150 (- 300 MISSILE-SPEED)) )
                         (make-tank (+ 50 TANK-SPEED) 1)))

(check-random (advance-game (make-game (list (make-invader -1 100 -12) ) (list (make-missile 150 300) ) (make-tank 50 1)))
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? (list (make-invader -1 100 -12) )))
                             (cons (make-invader (random WIDTH) 0 12) (list (make-invader (+ -1 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12) ))
                             (list (make-invader (+ -1 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12) )) (list (make-missile 150 (- 300 MISSILE-SPEED)) )
                         (make-tank (+ 50 TANK-SPEED) 1)))

(check-random (advance-game (make-game (list (make-invader 150 100 12) ) (list (make-missile 150 -1) ) (make-tank 50 1)))
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? (list (make-invader 150 100 12) )))
                             (cons (make-invader (random WIDTH) 0 12) (list (make-invader (+ 150 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12)))
                             (list (make-invader (+ 150 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12))) empty 
                         (make-tank (+ 50 TANK-SPEED) 1)))

(check-random (advance-game (make-game (list (make-invader 150 100 12) ) (list (make-missile 150 300) ) (make-tank 0 -1)))
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? (make-invader 150 100 12)))
                             (cons (make-invader (random WIDTH) 0 12) (list (make-invader (+ 150 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12) ))
                             (list (make-invader (+ 150 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12) )) (list (make-missile 150 (- 300 MISSILE-SPEED)) )
                         (make-tank 0 -1)))

(check-random (advance-game (make-game (list (make-invader 150 100 12) ) (list (make-missile 150 300) ) (make-tank WIDTH 1)))
              (make-game (if (or (< (random 1000) INVADE-RATE) (empty? (list (make-invader 150 100 12) )))
                             (cons (make-invader (random WIDTH) 0 12) (list (make-invader (+ 150 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12) ))
                             (list (make-invader (+ 150 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12) )) (list (make-missile 150 (- 300 MISSILE-SPEED)) )
                         (make-tank WIDTH 1)))


;; (define (advance-game g) g) ;; stub

(define (advance-game g)
  (make-game (if (or (< (random 1000) INVADE-RATE) (empty? (game-invaders g)))
                 (cons (make-invader (random WIDTH) 0 12) (advance-invaders (game-invaders g) (game-missiles g)))
                 (advance-invaders (game-invaders g) (game-missiles g)))
             (advance-missiles (game-missiles g) (game-invaders g))
             (advance-tank (game-tank g))))

;; ListOfInvaders ListOfMissiles -> ListOfInvaders
;; moves them down by invader-y-speed and left or right by invader-x-speed depending of the sign of dx if they aren't hit by a missile if they are they disappear

(check-expect (advance-invaders empty empty) empty)
(check-expect (advance-invaders LOI1 empty) (cons (make-invader (+ 150 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12) empty))
(check-expect (advance-invaders LOI2 empty) (list (make-invader (+ 150 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 12) (make-invader (- 150 INVADER-X-SPEED) (+ HEIGHT INVADER-Y-SPEED) -10) ))
(check-expect (advance-invaders (list (make-invader WIDTH 100 12)) empty) (list (make-invader (- WIDTH INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) -12)))
(check-expect (advance-invaders (list (make-invader 100 80 12)) (list (make-missile 100 80))) empty)
(check-expect (advance-invaders (list (make-invader 100 80 12)) (list (make-missile 100 (+ 80 HIT-RANGE)))) empty)
(check-expect (advance-invaders (list (make-invader 100 80 12)) (list (make-missile 100 (- 80 HIT-RANGE)))) empty)
(check-expect (advance-invaders (list (make-invader 100 80 12)) (list (make-missile 100 (+ 80 5)))) empty)
(check-expect (advance-invaders (list (make-invader 100 80 12)) (list (make-missile 100 200) (make-missile 100 (- 80 5)))) empty)
(check-expect (advance-invaders (list (make-invader 100 80 12)) (list (make-missile 100 (+ (+ 80 HIT-RANGE) 1)))) (list (make-invader (+ 100 INVADER-X-SPEED) (+ 80 INVADER-Y-SPEED) 12)))
(check-expect (advance-invaders (list (make-invader 100 80 12)) (list (make-missile 100 200) (make-missile (+ 100 HIT-RANGE) 80))) empty)
(check-expect (advance-invaders (list (make-invader 100 80 12)) (list (make-missile (- 100 HIT-RANGE) 80))) empty)
(check-expect (advance-invaders (list (make-invader 100 80 12)) (list (make-missile (+ 100 5) 80))) empty)
(check-expect (advance-invaders (list (make-invader 100 80 12)) (list (make-missile 100 200) (make-missile (- 100 5) 80))) empty)
(check-expect (advance-invaders (list (make-invader 100 80 12)) (list (make-missile 200 200) (make-missile (+ (+ 100 HIT-RANGE) 1) 80))) (list (make-invader (+ 100 INVADER-X-SPEED) (+ 80 INVADER-Y-SPEED) 12)))
              
;; (define (advance-invaders loi lom) empty) ;stub
(define (advance-invaders loi lom)
  (cond [(empty? loi) empty]
        [(ishit? (first loi) lom) (advance-invaders (rest loi) lom)]
        [else (cons (advance-invader (first loi)) (advance-invaders (rest loi) lom))]))

;; Invader ListOfMissiles -> Boolean
;; checks for the given invader if any existing missile collided with it (i.e: missile is inside the hit range for the x-axis and inside the hit range for the y-axis)
(check-expect (ishit? (make-invader 100 80 12) (list (make-missile 100 200) (make-missile 100 80))) true)
(check-expect (ishit? (make-invader 100 80 12) (list (make-missile 100 200) (make-missile 100 (+ 80 HIT-RANGE)))) true)
(check-expect (ishit? (make-invader 100 80 12) (list (make-missile 100 200) (make-missile 100 (- 80 HIT-RANGE)))) true)
(check-expect (ishit? (make-invader 100 80 12) (list (make-missile 100 200) (make-missile 100 (+ 80 5)))) true)
(check-expect (ishit? (make-invader 100 80 12) (list (make-missile 100 200) (make-missile 100 (- 80 5)))) true)
(check-expect (ishit? (make-invader 100 80 12) (list (make-missile 100 200) (make-missile 100 (+ (+ 80 HIT-RANGE) 1)))) false)
(check-expect (ishit? (make-invader 100 80 12) (list (make-missile 100 200) (make-missile (+ 100 HIT-RANGE) 80))) true)
(check-expect (ishit? (make-invader 100 80 12) (list (make-missile 100 200) (make-missile (- 100 HIT-RANGE) 80))) true)
(check-expect (ishit? (make-invader 100 80 12) (list (make-missile 100 200) (make-missile (+ 100 5) 80))) true)
(check-expect (ishit? (make-invader 100 80 12) (list (make-missile 100 200) (make-missile (- 100 5) 80))) true)
(check-expect (ishit? (make-invader 100 80 12) (list (make-missile 100 200) (make-missile (- 100 5) (+ 80 5)))) true)
(check-expect (ishit? (make-invader 100 80 12) (list (make-missile 100 200) (make-missile (+ (+ 100 HIT-RANGE) 1) 80))) false)

;; (define (ishit? i lom) false) ;stub
(define (ishit? i lom)
  (cond [(empty? lom) false]
        [else
         (if (and (and (>= (missile-x (first lom)) (- (invader-x i) HIT-RANGE)) (<= (missile-x (first lom)) (+ (invader-x i) HIT-RANGE)))
                  (and (>= (missile-y (first lom)) (- (invader-y i) HIT-RANGE)) (<= (missile-y (first lom)) (+ (invader-y i) HIT-RANGE))))
             true
             (ishit? i (rest lom)))]))


;; Invader -> Invader
;; moves the invader down by invader-y-speed and left or right by invader-x-speed depending of the sign of dx
(check-expect (advance-invader (make-invader 0 0 1)) (make-invader INVADER-X-SPEED INVADER-Y-SPEED 1))
(check-expect (advance-invader (make-invader 100 100 1)) (make-invader (+ 100 INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) 1))
(check-expect (advance-invader (make-invader 0 0 -1)) (make-invader INVADER-X-SPEED INVADER-Y-SPEED 1))
(check-expect (advance-invader (make-invader WIDTH 100 12)) (make-invader (- WIDTH INVADER-X-SPEED) (+ 100 INVADER-Y-SPEED) -12))
(check-expect (advance-invader (make-invader (- WIDTH 1) 100 12)) (make-invader WIDTH (+ 100 INVADER-Y-SPEED) 12))
;; (define (advance-invader i) i) ;stub
(define (advance-invader invader)
  (cond
    [(and (positive? (invader-dx invader)) (>= (invader-x invader) WIDTH)) (make-invader (- (invader-x invader) INVADER-X-SPEED) (+ (invader-y invader) INVADER-Y-SPEED) (* -1 (invader-dx invader)))]
    [(and (negative? (invader-dx invader)) (<= (invader-x invader) 0)) (make-invader (+ (invader-x invader) INVADER-X-SPEED) (+ (invader-y invader) INVADER-Y-SPEED) (* -1 (invader-dx invader)))]
    [(and (positive? (invader-dx invader)) (> (+ (invader-x invader) INVADER-X-SPEED) WIDTH)) (make-invader WIDTH (+ (invader-y invader) INVADER-Y-SPEED) (invader-dx invader))]
    [(and (negative? (invader-dx invader)) (< (- (invader-x invader) INVADER-X-SPEED) 0)) (make-invader 0 (+ (invader-y invader) INVADER-Y-SPEED) (invader-dx invader))]
    [(positive? (invader-dx invader)) (make-invader (+ (invader-x invader) INVADER-X-SPEED) (+ (invader-y invader) INVADER-Y-SPEED) (invader-dx invader))]
    [else (make-invader (- (invader-x invader) INVADER-X-SPEED) (+ (invader-y invader) INVADER-Y-SPEED) (invader-dx invader))]))

;; ListOfMissiles ListOfInvaders -> ListOfMissiles
;; moves the missiles up untill the hit an invader or hit the end of screen

(check-expect (advance-missiles empty empty) empty)
(check-expect (advance-missiles (list (make-missile 0 0)) empty) (list (make-missile 0 (- 0 MISSILE-SPEED))))
(check-expect (advance-missiles (list (make-missile 5 5) (make-missile 100 100)) empty) (list (make-missile 5 (- 5 MISSILE-SPEED)) (make-missile 100 (- 100 MISSILE-SPEED))))
(check-expect (advance-missiles (list (make-missile 65 0)) empty) (list (make-missile 65 (- 0 MISSILE-SPEED))))
(check-expect (advance-missiles (list (make-missile 65 -23)) empty) empty)
;; (define (advance-missiles lom loi) empty) ;stub

(define (advance-missiles lom loi)
  (cond [(empty? lom) empty]
        [(and (>= (missile-y (first lom)) 0) (ismissed? (first lom) loi)) (cons (advance-missile (first lom)) (advance-missiles (rest lom) loi))]
        [else (advance-missiles (rest lom) loi)]))

;; Missile ListOfInvaders -> Boolean
;; checks for the given missile if there exists an invader which it collides with if missed return true else false
(check-expect (ismissed? (make-missile 100 80) (list (make-invader 100 80 12))) false)
(check-expect (ismissed? (make-missile 100 80) (list (make-invader 100 (+ 80 HIT-RANGE) 12))) false)
(check-expect (ismissed? (make-missile 100 80) (list (make-invader 100 (- 80 HIT-RANGE) 12))) false)
(check-expect (ismissed? (make-missile 100 80) (list (make-invader 100 (+ 80 5) 12))) false)
(check-expect (ismissed? (make-missile 100 80) (list (make-invader 100 (- 80 5) 12))) false)
(check-expect (ismissed? (make-missile 100 80) (list (make-invader 100 (+ (+ 80 HIT-RANGE) 1) 12))) true)
(check-expect (ismissed? (make-missile 100 80) (list (make-invader (+ 100 HIT-RANGE) 80 12))) false)
(check-expect (ismissed? (make-missile 100 80) (list (make-invader (- 100 HIT-RANGE) 80 12))) false)
(check-expect (ismissed? (make-missile 100 80) (list (make-invader (- 100 5) 80 12))) false)
(check-expect (ismissed? (make-missile 100 80) (list (make-invader (+ 100 5) 80 12))) false)
(check-expect (ismissed? (make-missile 100 80) (list (make-invader (+ (+ 100 HIT-RANGE) 1) 80 12))) true)

;; (define (ismissed? m loi) false) ;stub
(define (ismissed? m loi)
  (cond [(empty? loi) true]
        [else
         (if (and (and (>= (missile-x m) (- (invader-x (first loi)) HIT-RANGE)) (<= (missile-x m) (+ (invader-x (first loi)) HIT-RANGE)))
                  (and (>= (missile-y m) (- (invader-y (first loi)) HIT-RANGE)) (<= (missile-y m) (+ (invader-y (first loi)) HIT-RANGE))))
             false
             (ismissed? m (rest loi)))]))

;; Missile -> Missile
;; moves the missile up untill the hit an invader or hit the end of screen
(check-expect (advance-missile (make-missile 5 5)) (make-missile 5 (- 5 MISSILE-SPEED)))
(check-expect (advance-missile (make-missile 65 0)) (make-missile 65 (- 0 MISSILE-SPEED)))
;; (define (advance-missile m) m) ;stub
(define (advance-missile m)
  (make-missile (missile-x m) (- (missile-y m) MISSILE-SPEED)))

;; Tank -> Tank
;; moves the tank right or left or it remains

(check-expect (advance-tank (make-tank 2 1)) (make-tank (+ 2 (* 1 TANK-SPEED)) 1))
(check-expect (advance-tank (make-tank 10 -1)) (make-tank (+ 10 (* -1 TANK-SPEED)) -1))
(check-expect (advance-tank (make-tank 5 0)) (make-tank (+ 5 (* 0 TANK-SPEED)) 0))
(check-expect (advance-tank (make-tank 0 -1)) (make-tank 0 -1))
(check-expect (advance-tank (make-tank WIDTH 1)) (make-tank WIDTH 1))
;; (define (advance-tank t) t) ;stub

(define (advance-tank t)
  (cond
    [(and (= (tank-dir t) 1) (>= (tank-x t) WIDTH)) (make-tank WIDTH (tank-dir t))]
    [(and (= (tank-dir t) -1) (<= (tank-x t) 0)) (make-tank 0 (tank-dir t))]
    [(and (= (tank-dir t) 1) (> (+ (tank-x t) TANK-SPEED) WIDTH)) (make-tank WIDTH (tank-dir t))]
    [(and (= (tank-dir t) -1) (< (- (tank-x t) TANK-SPEED) 0)) (make-tank 0 (tank-dir t))]
    [else (make-tank (+ (tank-x t) (* (tank-dir t) TANK-SPEED)) (tank-dir t))]))

;; g -> Image
;; renders the tank , the invaders and the bullets 

(check-expect (render (make-game empty empty (make-tank (/ WIDTH 2) 1)))
              (place-image BLANK 0 0
                           (place-image BLANK 0 0
                                        (place-image TANK (/ WIDTH 2) (- HEIGHT TANK-HEIGHT/2) MTS))))
(check-expect (render (make-game (list (make-invader 150 100 12) ) (list (make-missile 150 300) ) (make-tank 50 1)))
              (place-image INVADER 150 100 (place-image BLANK 0 0
                                                        (place-image MISSILE 150 300 (place-image BLANK 0 0
                                                                                                  (place-image TANK 50 (- HEIGHT TANK-HEIGHT/2) MTS))))))
(check-expect (render (make-game (list (make-invader 150 100 12) (make-invader 150 HEIGHT -10) )
                                 (list (make-missile 150 300) (make-missile 150 (- 100 1) ) )
                                 (make-tank 50 1)))
              (place-image INVADER 150 100 (place-image INVADER 150 HEIGHT (place-image BLANK 0 0
                                                                                        (place-image MISSILE 150 300 (place-image MISSILE 150 99 (place-image BLANK 0 0
                                                                                                                                                              (place-image TANK 50 (- HEIGHT TANK-HEIGHT/2) MTS))))))))


(check-expect (render (make-game (list (make-invader 150 100 12) (make-invader 150 HEIGHT -10) )
                                 (list (make-missile 150 300) (make-missile 150 (- 100 HIT-RANGE) ) )
                                 (make-tank 50 1)))
              (place-image INVADER 150 100 (place-image INVADER 150 HEIGHT (place-image BLANK 0 0
                                                                                        (place-image MISSILE 150 300 (place-image MISSILE 150 (- 100 HIT-RANGE) (place-image BLANK 0 0
                                                                                                                                                                             (place-image TANK 50 (- HEIGHT TANK-HEIGHT/2) MTS))))))))
(check-expect (render (make-game (list (make-invader 150 100 12) (make-invader 150 HEIGHT -10) )
                                 (list (make-missile 150 300) (make-missile 150 (+ 100 HIT-RANGE) ) )
                                 (make-tank 50 1)))
              (place-image INVADER 150 100 (place-image INVADER 150 HEIGHT (place-image BLANK 0 0
                                                                                        (place-image MISSILE 150 300 (place-image MISSILE 150 (+ 100 HIT-RANGE) (place-image BLANK 0 0
                                                                                                                                                                             (place-image TANK 50 (- HEIGHT TANK-HEIGHT/2) MTS))))))))


;; (define (render g) MTS) ;stub
(define (render g)
  (render-invaders (game-invaders g) g))

;; ListOfInvaders G -> Image
;; renders the invaders
(check-expect (render-invaders (list (make-invader 150 100 12)) (make-game (list (make-invader 150 100 12) ) (list (make-missile 150 300) ) (make-tank 50 1)))
              (place-image INVADER 150 100 (place-image BLANK 0 0
                                                        (place-image MISSILE 150 300 (place-image BLANK 0 0
                                                                                                  (place-image TANK 50 (- HEIGHT TANK-HEIGHT/2) MTS))))))
(check-expect (render-invaders (list (make-invader 150 100 12) (make-invader 150 HEIGHT -10) ) (make-game (list (make-invader 150 100 12) (make-invader 150 HEIGHT -10) )
                                                                                                          (list (make-missile 150 300) (make-missile 150 (+ 100 HIT-RANGE) ) )
                                                                                                          (make-tank 50 1)))
              (place-image INVADER 150 100 (place-image INVADER 150 HEIGHT (place-image BLANK 0 0
                                                                                        (place-image MISSILE 150 300 (place-image MISSILE 150 (+ 100 HIT-RANGE) (place-image BLANK 0 0
                                                                                                                                                                             (place-image TANK 50 (- HEIGHT TANK-HEIGHT/2) MTS))))))))
;; (define (render-invaders loi g) MTS) ;stub
(define (render-invaders loi g)
  (cond [(empty? loi) (place-image BLANK 0 0 (render-missiles (game-missiles g) g))]
        [else
         (place-image INVADER (invader-x (first loi)) (invader-y (first loi)) (render-invaders (rest loi) g))]))

;; ListOfMissiles Game -> Image
;; render the missiles
(check-expect (render-missiles (list (make-missile 150 300) ) (make-game (list (make-invader 150 100 12) ) (list (make-missile 150 300) ) (make-tank 50 1)))
              (place-image MISSILE 150 300 (place-image BLANK 0 0
                                                        (place-image TANK 50 (- HEIGHT TANK-HEIGHT/2) MTS))))
(check-expect (render-missiles (list (make-missile 150 300) (make-missile 150 (+ 100 HIT-RANGE) ) ) (make-game (list (make-invader 150 100 12) (make-invader 150 HEIGHT -10) )
                                                                                                               (list (make-missile 150 300) (make-missile 150 (+ 100 HIT-RANGE) ) )
                                                                                                               (make-tank 50 1)))
              (place-image MISSILE 150 300 (place-image MISSILE 150 (+ 100 HIT-RANGE) (place-image BLANK 0 0
                                                                                                   (place-image TANK 50 (- HEIGHT TANK-HEIGHT/2) MTS)))))           
;; (define (render-missiles lom  g) MTS) ;stub
(define (render-missiles lom g)
  (cond [(empty? lom) (place-image BLANK 0 0 (place-image TANK (tank-x (game-tank g)) (- HEIGHT TANK-HEIGHT/2) MTS))]
        [else
         (place-image MISSILE (missile-x (first lom)) (missile-y (first lom)) (render-missiles (rest lom) g))]))


;; g KeyEvent -> g
;; if space is clicked spawn a bullet from the tanks position
;; if (left/right) is clicks change tanks dir to (left/right)

(check-expect (key-handler (make-game empty empty (make-tank (/ WIDTH 2) 1)) "a") (make-game empty empty (make-tank (/ WIDTH 2) 1)))
(check-expect (key-handler (make-game empty empty (make-tank (/ WIDTH 2) 1)) "left") (make-game empty empty (make-tank (/ WIDTH 2) -1)))
(check-expect (key-handler (make-game empty empty (make-tank (/ WIDTH 2) 1)) "right") (make-game empty empty (make-tank (/ WIDTH 2) 1)))
(check-expect (key-handler (make-game empty empty (make-tank (/ WIDTH 2) 1)) " ") (make-game empty (list (make-missile (/ WIDTH 2) (- HEIGHT TANK-HEIGHT/2)))
                                                                                             (make-tank (/ WIDTH 2) 1)))
;; (define (key-handler g kevt) g) ;stub
(define (key-handler g kevt)
  (cond [(key=? kevt "left") (make-game (game-invaders g) (game-missiles g) (make-tank (tank-x (game-tank g)) -1))]
        [(key=? kevt "right") (make-game (game-invaders g) (game-missiles g) (make-tank (tank-x (game-tank g)) 1))]
        [(key=? kevt " ") (make-game (game-invaders g) (cons (make-missile (tank-x (game-tank g)) (- HEIGHT TANK-HEIGHT/2)) (game-missiles g)) (make-tank (tank-x (game-tank g)) (tank-dir (game-tank g))))]
        [else g]))

;; g KeyEvent -> g
;; if (left/right) is released change tanks dir to 0(hold position)

(check-expect (rel-handler (make-game empty empty (make-tank (/ WIDTH 2) 1)) "a") (make-game empty empty (make-tank (/ WIDTH 2) 1)))
(check-expect (rel-handler (make-game empty empty (make-tank (/ WIDTH 2) 1)) "left") (make-game empty empty (make-tank (/ WIDTH 2) 0)))
(check-expect (rel-handler (make-game empty empty (make-tank (/ WIDTH 2) 1)) "right") (make-game empty empty (make-tank (/ WIDTH 2) 0)))
(check-expect (rel-handler (make-game empty empty (make-tank (/ WIDTH 2) 1)) " ") (make-game empty empty (make-tank (/ WIDTH 2) 1)))
;; (define (rel-handler g kevt) g) ;stub
(define (rel-handler g kevt)
  (cond [(key=? kevt "left") (make-game (game-invaders g) (game-missiles g) (make-tank (tank-x (game-tank g)) 0))]
        [(key=? kevt "right") (make-game (game-invaders g) (game-missiles g) (make-tank (tank-x (game-tank g)) 0))]
        [else g]))

;; g -> Boolean
;; when an invader reached the bottom of the screen return true else return false
(check-expect (istouched? (make-game (list (make-invader 150 100 12) ) (list (make-missile 150 300) ) (make-tank 50 1))) false)
(check-expect (istouched? (make-game (list (make-invader 150 HEIGHT 12) ) (list (make-missile 150 300) ) (make-tank 50 1))) true)
(check-expect (istouched? (make-game (list (make-invader 150 (+ HEIGHT 10) 10) ) (list (make-missile 150 300) ) (make-tank 50 1))) true)

;; (define (istouched? g) false) ;stub
(define (istouched? g)
  (istouched?? (game-invaders g)))

;; ListOfInvaders -> Boolean
;; checks if any invader is at y-position HEIGHT
(check-expect (istouched?? (list (make-invader 150 100 12) )) false)
(check-expect (istouched?? (list (make-invader 150 HEIGHT 12) )) true)
(check-expect (istouched?? (list (make-invader 150 (+ HEIGHT 10) 10) )) true)
;; (define (istouched1?? loi) false) ;stub
(define (istouched?? loi)
  (cond [(empty? loi) false]
        [else
         (if (>= (invader-y (first loi)) HEIGHT)
             true
             (istouched?? (rest loi)))]))

