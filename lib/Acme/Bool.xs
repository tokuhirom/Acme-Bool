#ifdef __cplusplus
extern "C" {
#endif

#define PERL_NO_GET_CONTEXT /* we want efficiency */
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#ifdef __cplusplus
} /* extern "C" */
#endif

#define NEED_newSVpvn_flags
#include "ppport.h"

static bool
my_is_bool(pTHX_ SV* const sv) {
    const AMT* amt;

    if(!SvROK(sv)){
        return FALSE;
    }

    /* Return if non SV ref */
    switch (SvTYPE(SvRV(sv))) {
    case SVt_PVAV:
    case SVt_PVHV:
    case SVt_PVCV:
    case SVt_PVGV:
    case SVt_PVIO:
    case SVt_PVFM:
        return FALSE;
    }

    /* Return if the value does not have a magic */
    if(!SvAMAGIC(sv)) return FALSE;

    /* The value has 'bool' overloading */
    amt = (AMT*)mg_find((SV*)SvSTASH(SvRV(sv)), PERL_MAGIC_overload_table)->mg_ptr;
    assert(amt);
    assert(AMT_AMAGIC(amt));
    return amt->table[bool__amg] ? TRUE : FALSE;
}

MODULE = Acme::Bool    PACKAGE = Acme::Bool

PROTOTYPES: DISABLE

void
is_bool(SV *sv)
CODE:
{
    ST(0) = boolSV(my_is_bool(aTHX_ sv));
}
