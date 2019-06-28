;;;
;;; Ejercicios CLIPS 2018
;;; Alumno: Daniel Bolaños Martínez
;;;

;;; Ejercicio 3: Escribir y leer datos de un fichero.

;;; b) Leer.

(defrule openfile
	(declare (salience 30))
	=>
	(open "DatosT.txt" mydata)
	(assert (SeguirLeyendo))
)

(defrule LeerValoresCierreFromFile
	(declare (salience 20))
	?f <- (SeguirLeyendo)
	=>
	(bind ?Leido (read mydata))
	(retract ?f)
	(if (neq ?Leido EOF) then
		(assert (T ?Leido (read mydata)(read mydata)))
		(assert (SeguirLeyendo)))
)

(defrule closefile
	(declare (salience 10))
	=>
	(close mydata)
)