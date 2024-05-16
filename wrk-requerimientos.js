self.onmessage = function(evento){    
    var myRequest = new Request('/prt-requerimientos');      //No debe incluir ningun include
    //console.log(evento.data)
    self.postMessage({status:1});
    const params = {
        search : '',
        start : 0,
        USR_Id : evento.data.USR_Id,
        USR_Identificador: evento.data.USR_Identificador,
        FLU_Id : evento.data.FLU_Id,
        Tipo: evento.data.Tipo
    }
    const options = {
        method : 'POST',
        body: JSON.stringify( params )
    }
    fetch(myRequest,options)
        .then(res => res.json())
        .then(data => {
            data.status=0
            this.postMessage(data);
            self.close;
    })
}