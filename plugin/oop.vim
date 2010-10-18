"{{{1 Начало
scriptencoding utf-8
if (exists("s:g.pluginloaded") && s:g.pluginloaded) ||
            \exists("g:oopOptions.DoNotLoad")
    finish
"{{{1 Первая загрузка
elseif !exists("s:g.pluginloaded")
    "{{{2 Объявление переменных
    "{{{3 Словари с функциями
    " Функции для внутреннего использования
    let s:F={
                \"plug": {},
                \"main": {},
                \ "oop": {},
            \}
    lockvar 1 s:F
    "{{{3 Глобальная переменная
    let s:g={}
    let s:g.classes={}
    let s:g.load={}
    let s:g.pluginloaded=0
    let s:g.c={}
    let s:g.load.scriptfile=expand("<sfile>")
    "{{{3 Словарные функции
    let s:g.load.df=[
                \["registerclass", "oop.class",
                \   {   "model": "optional",
                \    "required": [["not", ["keyof", s:g.classes]]],
                \    "optional": [[["type", type({})],     {}, {}],
                \                 [["type", type({})],     {}, {}],
                \                 [["alllst", ["keyof", s:g.classes]],
                \                                          {}, []]]}],
                \["getinstance", "oop.instance", {}],
                \["instanceof", "oop.instanceof", {"model": "simple",
                \                               "required": [["keyof",
                \                                             s:g.classes],
                \                                            ["type", type({})]]
                \                                 }],
            \]
    "{{{3 sid
    function s:SID()
        return matchstr(expand('<sfile>'), '\d\+\ze_SID$')
    endfun
    let s:g.scriptid=s:SID()
    delfunction s:SID
    "{{{2 Регистрация дополнения
    let s:F.plug.load=load#LoadFuncdict()
    let s:g.reginfo=s:F.plug.load.registerplugin({
                \"apiversion": "0.0",
                \"funcdict": s:F,
                \"globdict": s:g,
                \"scriptfile": s:g.load.scriptfile,
                \"oprefix": 'oop',
                \"dictfunctions": s:g.load.df,
                \"sid": s:g.scriptid,
                \"requires": [["load", '0.0']],
            \})
    let s:F.main.eerror=s:g.reginfo.functions.eerror
    let s:F.main.option=s:g.reginfo.functions.option
    finish
    "}}}2
endif
"{{{1 Вторая загрузка
let s:g.pluginloaded=1
"{{{2 Выводимые сообщения
let s:g.p={
            \"emsg": {
            \   "classexists": "Class with such name already exists",
            \     "classnfnd": "Class with such name not found",
            \},
            \"etype": {
            \   "perm": "PermissionDenied",
            \   "iarg": "InvalidArgument",
            \},
        \}
call add(s:g.load.df[0][2].required[0], s:g.p.emsg.classexists)
call add(s:g.load.df[0][2].optional[2][0][1], s:g.p.emsg.classnfnd)
unlet s:g.load
"{{{1 Вторая загрузка — функции
"{{{2 oop: class, instance
"{{{3 oop.setfunctions
function s:F.oop.setfunctions(class, functions, parents)
    if a:functions!={}
        if !has_key(a:class, "F")
            let a:class.F={}
        endif
        call extend(a:class.F, a:functions, "keep")
    endif
    for parent in a:parents
        call s:F.oop.setfunctions(a:class, get(s:g.classes[parent], "F", {}),
                    \             get(s:g.classes[parent], "parents", []))
    endfor
endfunction
"{{{3 oop.class
function s:F.oop.class(name, functions, variables, parents)
    let class={}
    let s:g.classes[a:name]=class
    call s:F.oop.setfunctions(class, filter(copy(a:functions),
                \                           'type(v:val)==2'),
                \             a:parents)
    if has_key(class, "F")
        lockvar! class.F
    endif
    if a:variables!={}
        let class.vars=a:variables
    else
        let class.vars={}
    endif
    if a:parents!=[]
        let class.parents=copy(a:parents)
        lockvar! class.parents
    endif
    let class.instances=[]
    lockvar class
    unlockvar class.instances
    let r={}
    let escapedname=substitute(string(a:name), '\n', "'.\"\\n\".'", 'g')
    execute      "function r.delete()\n".
                \"    unlockvar s:g.classes[".escapedname."]\n"
                \"    unlet s:g.classes[".escapedname."]\n".
                \"endfunction"
    return r.delete
endfunction
"{{{3 oop.getc
function s:F.oop.getc(class, first)
    let r={}
    if a:class.vars!={}
        call extend(r, a:class.vars)
    endif
    if has_key(a:class, "F") && a:first
        call extend(r, a:class.F)
    endif
    return r
endfunction
"{{{3 oop.setinstance
function s:F.oop.setinstance(class, instance, first, args)
    if has_key(a:class, "parents")
        if len(a:class.parents)==1
            let super=s:F.oop.getc(s:g.classes[a:class.parents[0]], 1)
        else
            let super={}
            for parent in a:class.parents
                let super[parent]=s:F.oop.getc(s:g.classes[parent], 1)
            endfor
        endif
        for parent in a:class.parents
            call s:F.oop.setinstance(s:g.classes[parent], a:instance, 0, a:args)
        endfor
    else
        let super=0
    endif
    call extend(a:instance, s:F.oop.getc(a:class, a:first))
    let hasconstructor=(has_key(a:class, "F") && has_key(a:class.F, "__init__"))
    if a:first && hasconstructor
        call call(a:class.F.__init__, [super]+a:args, a:instance)
    endif
    call add(a:class.instances, a:instance)
endfunction
"{{{3 oop.instance
function s:F.oop.instance(name, ...)
    let selfname='oop.instance'
    if !has_key(s:g.classes, a:name)
        return s:F.main.eerror(selfname, "iarg", ["classnfnd"], a:name)
    endif
    let class=s:g.classes[a:name]
    let instance={"__class__": a:name,
                \ "__variables__": class.vars}
    call s:F.oop.setinstance(class, instance, 1, a:000)
    return instance
endfunction
"{{{3 oop.instanceof
function s:F.oop.instanceof(name, instance)
    for instance in s:g.classes[a:name].instances
        if a:instance is instance
            return 1
        endif
    endfor
    return 0
endfunction
"{{{2 main: eerror, destruct, option
"{{{3 main.destruct: выгрузить плагин
function s:F.main.destruct()
    unlet s:g
    unlet s:F
    return 1
endfunction
"{{{1
lockvar! s:F
lockvar! s:g
unlockvar! s:g.classes
" vim: ft=vim:ts=8:fdm=marker:fenc=utf-8

