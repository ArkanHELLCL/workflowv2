self.onmessage = function(evento){    
    var myRequest = new Request(evento.data.worker);      //No debe incluir ningun include    
    const params = {
        DRE_Id : evento.data.DRE_Id,
        INF_Id : evento.data.INF_Id,        
        wk2_usrtoken: evento.data.wk2_usrtoken,
        wk2_usrid: evento.data.wk2_usrid,
        wk2_usrperfil: evento.data.wk2_usrperfil
    }
    const options = {
        method : 'POST',
        body: JSON.stringify( params )
    }
    fetch(myRequest,options)
        .then(res => res.json())
        .then(data => {            
            this.postMessage({status:0});
            self.close;
        })
        .catch(err => {
            if(err){                
                this.postMessage({status:1,message:err.message});
                self.close;
            }
        });
}