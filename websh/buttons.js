if (document.images) {
        var prod_a = new Image();
        var prod_b = new Image();
        var docu_a = new Image();
        var docu_b = new Image();
        var supp_a = new Image();
        var supp_b = new Image();
        var ress_a = new Image();
        var ress_b = new Image();
        var down_a = new Image();
        var down_b = new Image();

        prod_a.src ="/websh/buttons/b_prod_a.gif";
        prod_b.src ="/websh/buttons/b_prod_b.gif";
        docu_a.src ="/websh/buttons/b_docu_a.gif";
        docu_b.src ="/websh/buttons/b_docu_b.gif";
        supp_a.src ="/websh/buttons/b_supp_a.gif";
        supp_b.src ="/websh/buttons/b_supp_b.gif";
        ress_a.src ="/websh/buttons/b_ress_a.gif";
        ress_b.src ="/websh/buttons/b_ress_b.gif";
        down_a.src ="/websh/buttons/b_down_a.gif";
        down_b.src ="/websh/buttons/b_down_b.gif";
}

function swap(img, type) {

        if(document.images) {
                document[img].src = "/websh/buttons/" + type + ".gif";
        }
}
