;;;
;;; Ejercicios CLIPS 2018
;;; Alumno: Daniel Bolaños Martínez
;;;

;;; Ejercicio 3: Escribir y leer datos de un fichero.

;;; a) Escribir.

;;; Fijamos n=3 y xi=x1
(deffacts ejemplos
	(T 1 2 3)
	(T 5 7 8)
	(T 0 5 6)
)

(defrule openfile2
	(declare (salience 30))
	=>
	(open "DatosT.txt" mydata "w")
 )

(defrule WriteData
	(declare (salience 20))
	?Borra <- (T ?x1 ?x2 ?x3)
	(not (exists (T ?xi ? ?)
		(test(< ?xi ?x1))))
	=>
	(printout mydata ?x1 " " ?x2 " " ?x3 crlf)
	(retract ?Borra)
 )

(defrule closefile2
	(declare (salience 10))
	=>
	(close mydata)
 )