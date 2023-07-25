$(document).ready(function(){
    
    var interval = null;

    if(history.forward(1))
        location.replace(history.forward(1))

    validar = function () {
        var i
        var ninguna = true		
        for (i=0; i<document.form_pregunta.respuesta_alumno.length; i++){
            if (document.form_pregunta.respuesta_alumno[i].checked){
                document.form_pregunta.submit()				
                ninguna = false
                break				
            }	
        }
        if (ninguna) { 
            alert ("Debes elegir una opción para continuar")
        }				  
    } 	    

    countdown = function (measure, ammount) {
        const timer = $('#timer')
        const s = $(timer).find('.seconds')
        const m = $(timer).find('.minutes')
        const h = $(timer).find('.hours')

        var seconds = 0
        var minutes = 0
        var hours = 0        

        var clockType = 'countdown';

        startClock(measure, ammount);  

        function pad(d) {
            return (d < 10) ? '0' + d.toString() : d.toString()
        }

        function startClock(measure, ammount) {
            hasStarted = false
            hasEnded = false

            seconds = 0
            minutes = 0
            hours = 0

            switch (measure) {
                case 's':
                    if (ammount > 3599) {
                        let hou = Math.floor(ammount / 3600)
                        hours = hou
                        let min = Math.floor((ammount - (hou * 3600)) / 60)
                        minutes = min;
                        let sec = (ammount - (hou * 3600)) - (min * 60)
                        seconds = sec
                    }
                    else if (ammount > 59) {
                        let min = Math.floor(ammount / 60)
                        minutes = min
                        let sec = ammount - (min * 60)
                        seconds = sec
                    }
                    else {
                        seconds = ammount
                    }
                    break
                case 'm':
                    if (ammount > 59) {
                        let hou = Math.floor(ammount / 60)
                        hours = hou
                        let min = ammount - (hou * 60)
                        minutes = min
                    }
                    else {
                        minutes = ammount
                    }
                    break
                case 'h':
                    hours = ammount
                    break
                default:
                    break
            }

            refreshClock()

            switch (clockType) {
                case 'countdown':
                    countdown()
                    break
                default:
                    break
            }
        }

        if (hours == 0 && minutes == 0 && seconds == 0 && hasStarted == true) {
            hasEnded = true
        }

        function countdown() {
            hasStarted = true
            if (hasEnded)
                refreshClock()  
            else
                interval = setInterval(() => {
                    if(hasEnded == false) {
                        if (seconds <= 60 && minutes == 0 && hours == 0) {
                            $(timer).find('span').addClass('red')
                        }

                        if(seconds == 0 && minutes == 0 || (hours > 0  && minutes == 0 && seconds == 0)) {
                            hours--
                            minutes = 59
                            seconds = 60
                            refreshClock()
                        }

                        if(seconds > 0) {
                            seconds--
                            refreshClock()
                        }
                        else if (seconds == 0) {
                            minutes--
                            seconds = 59
                            refreshClock()
                        }
                    }
                    else {
                        clearInterval(window.interval);   
                        refreshClock()
                    }
                }, 1000)            
        }

        function refreshClock() {
            if (hasEnded) {                                   
                $('#timer').remove()                                                            
                location.reload()                      
            }    
            else {
                $(s).text(pad(seconds))
                $(m).text(pad(minutes))
                if (hours < 0) {
                    $(s).text('00')
                    $(m).text('00')
                    $(h).text('00')
                } else {
                    $(h).text(pad(hours))
                }       
                if (seconds < 60 && minutes == 0 && hours == 0) {
                    $(timer).find('span').addClass('red')
                }
                if (hours == 0 && minutes == 0 && seconds == 0 && hasStarted == true) {
                    hasEnded = true
                }
            }
        }
    }

    stopClock = function () {
		clearInterval(interval)
		$('#timer').remove()        
    }
})
