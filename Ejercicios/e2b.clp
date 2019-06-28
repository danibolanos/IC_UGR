;;;
;;; Ejercicios CLIPS 2018
;;; Alumno: Daniel Bolaños Martínez
;;;

;;; Ejercicio 2: Obtener el valor mínimo de entre los campos de los hechos de un tipo.

;;; b) Datos tipo vector ordenado.

;;; Fijamos n=3 y xi=x1

(deffacts ejemplos
	(T 1 2 3)
	(T 0 4 6)
	(T 3 7 9)
)

(defrule minXiT
	(T ?x1 ?x2 ?x3)
	(not (exists (T ?xi ? ?)
		(test (< ?xi ?x1))))
	=>
	(printout t "El " ?x1 " es el valor minimo de los hechos T." crlf)
)
