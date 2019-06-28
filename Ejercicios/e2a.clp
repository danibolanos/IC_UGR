;;;
;;; Ejercicios CLIPS 2018
;;; Alumno: Daniel Bolaños Martínez
;;;

;;; Ejercicio 2: Obtener el valor mínimo de entre los campos de los hechos de un tipo.

;;; a) Datos definidos por Templates.

;;; Creamos un slot para el nombre y dos valores numéricos a comparar
(deftemplate T
	(slot Nombre)
	(slot Valor1)
	(slot Valor2)
)

(deffacts ejemplos
	(T (Nombre Salon) (Valor1 2) (Valor2 5))
	(T (Nombre Aseo) (Valor1 6) (Valor2 0))
)

(defrule minSdeT
	(T (Nombre ?n) (Valor1 ?n1) (Valor2 ?n2))
	=>
	(if (< ?n1 ?n2) 
	then
		(assert (MinT ?n ?n1))
    else
		(assert (MinT ?n ?n2))
	)
)

(defrule extraeMin
	(declare(salience -20))
	?Borra<-(MinT ?n ?x)
	=>
	(printout t "El " ?n " tiene el valor minimo " ?x "" crlf)
	(retract ?Borra)
)