static int Send_Page(request_rec *r)
{
    if (r->method_number != M_GET && r->method_number != M_POST) {
	return DECLINED;
    }
    ap_rputs("Hello, Braga!", r);
    return OK;
}
