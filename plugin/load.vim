"{{{1 Начало
"{{{2
scriptencoding utf-8
if (exists("s:g.pluginloaded") && s:g.pluginloaded) ||
            \exists("g:loadOptions.DoNotLoad")
    finish
endif
"{{{2 Объявление переменных
"{{{3 Словари с функциями
" Функции для внутреннего использования
let s:F={
            \"plug": {},
            \"cons": {},
            \"stuf": {},
            \"main": {},
            \ "mng": {},
            \ "reg": {},
            \"comm": {},
            \"comp": {},
            \"maps": {},
            \ "int": {},
            \  "au": {},
            \ "ses": {},
        \}
lockvar 1 s:F
"{{{3 Глобальная переменная
let s:g={}
let s:g.c={}
let s:g.load={}
let s:g.pluginloaded=1
let s:g.load.scriptfile=expand("<sfile>")
"{{{4 sid
function s:SID()
    return matchstr(expand('<sfile>'), '\d\+\ze_SID$')
endfunction
let s:g.scriptid=s:SID()
delfunction s:SID
"{{{4 Настройки по умолчанию
let s:g.c.options={
            \"DisableLoadChecks": ["bool", ""],
        \}
let s:g.defaultOptions={
            \"DisableLoadChecks": 1,
        \}
lockvar! s:g.defaultOptions
"{{{3 Команды и функции
" Определяет команды. Для значений ключей словаря см. :h :command. Если 
" некоторому ключу «key» соответствует непустая строка «str», то в аргументы 
" :command передаётся -key=str, иначе передаётся -key. Помимо ключей 
" :command, в качестве ключа словаря также используется строка «func». Ключ 
" «func» является обязательным и содержит функцию, которая будет вызвана при 
" запуске команды (без префикса s:F.).
let s:g.load.commands={
            \"Command": {
            \      "nargs": '+',
            \       "func": "mng.main",
            \   "complete": "customlist,s:_complete",
            \},
        \}
" Список видимых извне функции
let s:g.load.functions=[["Funcdict", "comm.rdict", {}]]
"{{{2 Выводимые сообщения
let s:g.p={
            \"emsg": {
            \    "1dct": "First argument to this function must be a dictionary",
            \    "2str": "Second argument to this function must be ".
            \            'a non-empty string',
            \    "bool": "Value must equal either to 0 or to 1",
            \   "procd": "While processing option %s for plugin %s ".
            \            "from dictionary %s found an error",
            \    "proc": "While processing option %s for plugin %s ".
            \            "found an error",
            \     "str": "Option must have type String",
            \   "fpref": "Function prefix must start either with g: or with a ".
            \            "capital latin letter and contain latin letters and ".
            \            "numbers",
            \   "cpref": "Command prefix must start with a capital latin ".
            \            "letter and contain latin letters and numbers",
            \    "preg": "Plugin already registered",
            \   "nplug": "Failed to find plugin %s",
            \   "nfunc": "Failed to find function %s",
            \    "ireg": "Invalid registration dictionary",
            \    "iopt": "Invalid option",
            \    "uopt": "Failed to find option %s",
            \   "cexst": "Failed to create command “%s” for plugin “%s”: ".
            \            "command already exists",
            \   "fexst": "Failed to create function “%s” for plugin “%s”: ".
            \            "function already exists",
            \   "imdef": "Invalid “s:g.defaultOptions._maps”",
            \   "ukmap": "Failed to find options for mapping named “%s” ".
            \            "defined in plugin “%s”",
            \   "ebmap": "Buffer mapping “%s” already defined by plugin %s",
            \   "egmap": "Global mapping “%s” already defined by plugin %s",
            \   "majap": "Major api version mismatch (%s required by %s): ".
            \            "%u≠%u",
            \   "minap": "Minor api version mismatch (%s required by %s): ".
            \            "%u<%u",
            \    "nreq": "Failed to load dependencies for plugin %s",
            \   "sesdw": "Unable to write to directory %s that contains ".
            \            "session file",
            \   "sesfx": "Unable to overwrite %s file",
            \   "sesnf": "Failed to create session file",
            \   "yamlf": "Failed to load yaml plugin",
            \    "sesr": "While restoring a session, failed to load plugin %s",
            \},
            \"etype": {
            \    "value": "InvalidValue",
            \   "syntax": "SyntaxError",
            \   "option": "InvalidOption",
            \     "perm": "PermissionDenied",
            \     "nfnd": "NotFound",
            \    "ofail": "OperationFailed",
            \      "req": "RequirementsUnsatisfied",
            \},
            \"th": ["SID", "Name", "File", "Status"],
            \"nfnd": "Not found",
        \}
lockvar! s:g.p
"{{{2 s:g.c.reg
let s:g.c.reg={}
let s:g.c.reg.func='^g:[[:alnum:]_]\+\|\u[[:alnum:]_]*$'
let s:g.c.reg.cmd='^\u[[:alnum:]_]*$'
let s:g.c.reg.tf='^[[:alnum:]_]\+$'
let s:g.c.reg.rf='^\([[:alnum:]_]\+.\)*[[:alnum:]_]\+$'
lockvar! s:g.c.reg
"{{{1 Функции
"{{{2 cons: eerror, option
"{{{3 cons.eerror
function s:F.cons.eerror(plugin, from, type, ...)
    let etype=((type(a:type)==type("") &&
                \   exists("a:plugin.g.p.etype") &&
                \   type(a:plugin.g.p.etype)==type({}) &&
                \   has_key(a:plugin.g.p.etype, a:type))?
                \(a:plugin.g.p.etype[a:type]):
                \(s:F.stuf.string(a:type)))
    let emsg=((exists("a:plugin.g.p.emsg") &&
                \   type(a:plugin.g.p.emsg)==type({}))?
                \(a:plugin.g.p.emsg):
                \({}))
    let dothrow=0
    let outmsgs=[]
    let args=a:000
    if len(args) && type(args[0])==type(0)
        let dothrow=!!args[0]
        let args=args[1:]
    endif
    for e in args
        if type(e)==type([])
            if e!=[] && type(e[0])==type("") && has_key(emsg, e[0])
                if len(e)>1
                    call add(outmsgs, call("printf",
                                \[s:F.stuf.string(emsg[e[0]])]+e[1:]))
                else
                    call add(outmsgs, emsg[e[0]])
                endif
            else
                call add(outmsgs, s:F.stuf.string(e))
            endif
        elseif type(e)==type("")
            call add(outmsgs, e)
        else
            call add(outmsgs, s:F.stuf.string(e))
        endif
        unlet e
    endfor
    let comm="(".join(outmsgs, ': ').")"
    let msg=(a:plugin.name)."/".s:F.stuf.string(a:from).":".(etype).(comm)
    echohl Error
    echo msg
    echohl None
    if dothrow
        throw msg
    endif
    return 0
endfunction
"{{{3 cons.option
"{{{4 s:g.c.maps
let s:g.c.maps=["dict", [[["any", ""], ["type", type("")]]]]
"}}}4
function s:F.cons.option(plugin, option)
    let selfname="cons.option"
    "{{{4 Объявление переменных
    if type(a:option)!=type("")
        return s:F.cons.eerror(a:plugin, selfname, "value", 1, s:g.p.emsg.str,
                    \s:F.stuf.string(a:option))
    endif
    let oname=(a:plugin.optionprefix)."Options"
    let defaults=((exists("a:plugin.g.defaultOptions") &&
                \   type(a:plugin.g.defaultOptions)==type({}))?
                \(a:plugin.g.defaultOptions):
                \({}))
    "{{{4 Настройка _maps
    if a:option==#"_maps"
        let r=[{}, {}, {}]
        if has_key(a:plugin, "mappings")
            if !s:F.plug.chk.checkargument(s:g.c.intmaps, a:plugin.mappings)
                return s:F.cons.eerror(a:plugin, selfname, "value", 1,
                            \          printf(s:g.p.emsg.proc, a:option,
                            \                 a:plugin.name),
                            \          s:g.p.emsg.imdef)
            endif
            let r[2]=a:plugin.mappings
        else
            return r
        endif
        if exists("b:".oname) && has_key(b:{oname}, "_maps")
            if !s:F.plug.chk.checkargument(s:g.c.maps, b:{oname}._maps)
                return s:F.cons.eerror(a:plugin, selfname, "value", 1,
                            \          printf(s:g.p.emsg.procd, a:option,
                            \                 a:plugin.name, 'b:'.oname),
                            \          s:g.p.emsg.iopt)
            endif
            let r[0]=b:{oname}._maps
        endif
        if exists("g:".oname) && has_key(g:{oname}, "_maps")
            if !s:F.plug.chk.checkargument(s:g.c.maps, g:{oname}._maps)
                return s:F.cons.eerror(a:plugin, selfname, "value", 1,
                            \          printf(s:g.p.emsg.procd, a:option,
                            \                 a:plugin.name, 'g:'.oname),
                            \          s:g.p.emsg.iopt)
            endif
            let r[1]=g:{oname}._maps
        endif
        return r
    "{{{4 Настройка _leader
    elseif a:option==#"_leader"
        if exists("g:".oname) && has_key(g:{oname}, "_leader")
            if type(g:{oname}._leader)==type("")
                return g:{oname}._leader
            else
                return s:F.cons.eerror(a:plugin, selfname, "value", 1,
                            \          printf(s:g.p.emsg.procd, a:option,
                            \                 a:plugin.name, 'g:'.oname),
                            \          s:g.p.emsg.iopt)
            endif
        elseif has_key(a:plugin, "leader")
            return a:plugin.leader
        endif
        return ""
    "{{{4 Настройка _disablemaps
    elseif a:option==#"_disablemaps"
        let r=0
        if exists("g:".oname) && has_key(g:{oname}, "_disablemaps")
            let r=!!(g:{oname}._disablemaps)
        elseif has_key(defaults, a:option)
            let r=!!(defaults[a:option])
        endif
        if index([0, 1], r)==-1
            return s:F.main.eerror(selfname, 'option', 1,
                        \          ["procd", a:option, a:plugin.name,
                        \           'g:'.oname],
                        \          ["bool"])
        endif
        return r
    "{{{4 Настройки _cprefix и _fprefix
    elseif a:option==#"_cprefix" || a:option==#"_fprefix"
        let pref=a:plugin[a:option[1:]]
        if exists("g:".oname) && has_key(g:{oname}, a:option)
            let pref=g:{oname}[a:option]
        endif
        if type(pref)!=type("")
            return s:F.main.eerror(selfname, 'option', 1,
                        \          ["procd", a:option, a:plugin.name,
                        \           'g:'.oname],
                        \          ["str"], s:F.stuf.string(pref))
        elseif a:option[1]==#"c" && pref!~#s:g.c.reg.cmd
            return s:F.main.eerror(selfname, 'option', 1,
                        \          ["procd", a:option, a:plugin.name,
                        \           'g:'.oname],
                        \          ["fpref"], pref)
        elseif a:option[1]==#"f" && pref!~#s:g.c.reg.func
            return s:F.main.eerror(selfname, 'option', 1,
                        \          ["procd", a:option, a:plugin.name,
                        \           'g:'.oname],
                        \          ["cpref"], pref)
        endif
        return pref
    endif
    "{{{4 chk
    let chk=((exists("a:plugin.g.c.options") &&
                \   type(a:plugin.g.c.options)==type({}) &&
                \   has_key(a:plugin.g.c.options, a:option))?
                \(a:plugin.g.c.options[a:option]):
                \(0))
    "{{{4 Получить настройку
    if exists("b:".oname) && has_key(b:{oname}, a:option)
        let src='b'
        let retopt=b:{oname}[a:option]
    elseif exists("g:".oname) && has_key(g:{oname}, a:option)
        let src='g'
        let retopt=g:{oname}[a:option]
    else
        if has_key(defaults, a:option)
            return defaults[a:option]
        else
            return s:F.cons.eerror(a:plugin, selfname, "value", 1,
                        \          printf(s:g.p.emsg.uopt, a:option))
        endif
    endif
    "{{{4 Проверить правильность
    let optstr=a:option."/".src
    if type(chk)!=type(0) && !s:F.plug.chk.checkargument(chk, retopt)
        return s:F.cons.eerror(a:plugin, selfname, "value", 1,
                    \          printf(s:g.p.emsg.procd, a:option, a:plugin.name,
                    \                 src.':'.oname),
                    \          s:g.p.emsg.iopt)
    endif
    "}}}4
    return retopt
endfunction
"{{{2 stuf: findnr, findpath, printtable, fdictstr, string, ...
"{{{3 s:Eval: доступ к внутренним переменным
" Внутренние переменные, в том числе s:F, недоступны в привязках
function s:Eval(var)
    return eval(a:var)
endfunction
let s:F.int["s:Eval"]=function("s:Eval")
"{{{3 stuf.squote
function s:F.stuf.squote(str)
    return "'".substitute(substitute(a:str, "'", '&&', 'g'),
                \         '\n', '''."\\n".''', 'g')."'"
endfunction
"{{{3 stuf.mapprepare
function s:F.stuf.mapprepare(str)
    return escape(substitute(
                \  substitute(
                \   substitute(
                \    substitute(a:str, '<', '<LT>', 'g'),
                \   ' ', '<SPACE>', 'g'),
                \  '\t', '<Tab>', 'g'),
                \ '\n', '<CR>', 'g') , '|')
endfunction
"{{{3 stuf.string
function s:F.stuf.string(obj)
    if type(a:obj)==type("")
        return a:obj
    endif
    try
        let r=string(a:obj)
    catch
        redir => r
        silent echo a:obj
        redir END
        let r=r[1:]
    endtry
    return r
endfunction
"{{{3 stuf.findf: Найти функцию по номеру
function s:F.stuf.findf(nr, pos, d, depth)
    if a:depth > &maxfuncdepth-10
        return 0
    endif
    if type(a:d)==2 && string(a:d)=~#"'".a:nr."'"
        return a:pos
    elseif type(a:d)==type({})
        for [key, Value] in items(a:d)
            let pos=s:F.stuf.findf(a:nr, a:pos."/".key, Value, a:depth+1)
            unlet Value
            if type(pos)==type("")
                return pos
            endif
        endfor
    endif
    return 0
endfunction
"{{{3 stuf.findr: Найти функцию по номеру
function s:F.stuf.findnr(nr)
    for [key, value] in items(s:g.reg.registered)
        let pos=s:F.stuf.findf(a:nr, "/".key, value.F, 0)
        if type(pos)==type("")
            return pos
        endif
    endfor
    if has_key(s:g.reg.unnamedfunctions, a:nr)
        return s:g.reg.unnamedfunctions[a:nr]
    endif
    return 0
endfunction
"{{{3 stuf.findpath: Найти номер функции
function s:F.stuf.findpath(path)
    let selfname="stuf.findpath"
    let s=split(a:path, '/')
    if s==[]
        return 0
    endif
    let [plugname; path]=s
    if !has_key(s:g.reg.registered, plugname)
        return s:F.main.eerror(selfname, "nfnd", ["nplug", plugname])
    endif
    let Fdict=s:g.reg.registered[plugname].F
    for component in path
        if type(Fdict)!=type({}) || !has_key(Fdict, component)
            return 0
        endif
        let Tmp=Fdict[component]
        unlet Fdict
        let Fdict=Tmp
        unlet Tmp
    endfor
    return Fdict
endfunction
"{{{3 stuf.strlen: получение длины строки
function s:F.stuf.strlen(stuf)
    return len(split(a:stuf, '\zs'))
endfunction
"{{{3 stuf.printl: printf{'%-*s', ...}
" Напечатать {stuf}, шириной {len}, выровненное по левому краю, оставшееся 
" пространство заполнив пробелами (вместо printf('%-*s', len, stuf)).
function s:F.stuf.printl(len, stuf)
    return a:stuf . repeat(" ", a:len-s:F.stuf.strlen(a:stuf))
endfunction
"{{{3 stuf.printtline: печать строки таблицы
" Напечатать одну линию таблицы
"   {line} — список строк таблицы,
" {lenlst} — список длин
function s:F.stuf.printtline(line, lenlst)
    let result=""
    let i=0
    while i<len(a:line)
        let result.=s:F.stuf.printl(a:lenlst[i], a:line[i])
        let i+=1
        if i<len(a:line)
            let result.="  "
        endif
    endwhile
    return result
endfunction
"{{{3 stuf.printtable: напечатать таблицу
" Напечатать таблицу с заголовками рядов {headers} и линиями {lines}.
" {headers}: список строк
"   {lines}: список списков строк
function s:F.stuf.printtable(header, lines)
    let lineswh=a:lines+[a:header]
    let columns=max(map(copy(lineswh), 'len(v:val)'))
    let lenlst=[]
    let i=0
    while i<columns
        call add(lenlst, max(map(copy(lineswh),
                    \'(i<len(v:val))?s:F.stuf.strlen(v:val[i]):0')))
        let i+=1
    endwhile
    if a:header!=[]
        echohl PreProc
        echo s:F.stuf.printtline(a:header, lenlst)
        echohl None
    endif
    echo join(map(copy(a:lines), 's:F.stuf.printtline(v:val, lenlst)'), "\n")
    return 1
endfunction
"{{{3 stuf.fdictstr
function s:F.stuf.fdictstr(dict, indent)
    if a:indent > &maxfuncdepth-10
        return []
    endif
    let result=[]
    for [key, Value] in items(a:dict)
        if type(Value)==type({})
            let list=s:F.stuf.fdictstr(Value, a:indent+1)
            if list!=[]
                let result+=[[a:indent, key, ""]]+list
            endif
        elseif type(Value)==2
            call add(result, [a:indent, key, Value])
        endif
        unlet Value
    endfor
    return result
endfunction
"{{{2 main: eerror, destruct, session
"{{{3 main.destruct: Выгрузить дополнение
function s:F.main.destruct()
    for f in keys(s:F.int)
        execute "delfunction ".f
    endfor
    if has_key(s:F.comp, "__complete")
        call s:F.plug.comp.delcomp(s:g.comp._cname)
    endif
    unlet s:F
    unlet s:g
    return 1
endfunction
"{{{3 main.session
function s:F.main.session(...)
    if empty(a:000)
        let r={}
        for [plugname, plugdict] in items(s:g.reg.registered)
            let r[plugname]={
                        \"status": plugdict.status,
                    \}
        endfor
        return r
    else
        let rdict=get(a:000, 0, {})
        for [plugname, plugopts] in items(rdict)
            let plugdict=s:F.comm.getpldict(plugname)
            let curstatus=plugdict.status
            let status=plugopts.status
            if curstatus!=#"loaded" && status==#"loaded"
                call s:F.comm.load(plugname)
            elseif curstatus==#""
                call s:F.main.eerror(selfname, "ofail", 1, ["sesr", plugname])
            endif
        endfor
        for plugname in keys(s:g.reg.registered)
            if !has_key(rdict, plugname) &&
                        \has_key(s:g.reg.registered, plugname)
                call s:F.comm.unload(plugname)
            endif
        endfor
    endif
endfunction
"{{{2 reg: register, unreg
"{{{3 s:g.reg
let s:g.reg={}
let s:g.reg.lazyload={}
let s:g.reg.registered={}
let s:g.reg.plugsids={}
let s:g.reg.unnamedfunctions={}
let s:g.reg.required={}
let s:g.reg.mapdict=[]
lockvar 1 s:g.reg
"{{{3 reg.register:  Зарегистрировать плагин
"{{{4 s:g.reg.mapdict
call extend(s:g.reg.mapdict, ["cprefix", "fprefix", "commands", "functions",
            \                 "dictfunctions", "mappings", "leader",])
lockvar! s:g.reg.mapdict
"}}}4
function s:F.reg.register(regdict)
    let selfname="reg.register"
    "{{{4 Проверка аргументов
    let plugname=fnamemodify(a:regdict.scriptfile, ":t:r")
    "{{{5 Если проверяющее дополнение не загружено
    if !has_key(s:g.reg.registered, "chk") && plugname!=#"load"
        runtime plugin/chk.vim
    endif
    "}}}5
    if !(plugname==#"chk" || plugname==#"load")
        if !has_key(s:F.plug, "chk")
            let s:F.plug.chk=s:F.comm.getfunctions("chk")
        endif
        if !s:F.main.option("DisableLoadChecks") &&
                    \!s:F.plug.chk.checkargument(s:g.c.register, a:regdict)
            return s:F.main.eerror(selfname, "value", 1, ["ireg"])
        endif
    endif
    if has_key(s:g.reg.registered, plugname)
        return s:F.main.eerror(selfname, "perm", ["preg"], plugname)
    endif
    "{{{4 au RegisterPluginPre, LoadPluginPre
    call s:F.au.doevent("RegisterPluginPre", plugname)
    if has_key(a:regdict, "oneload") && a:regdict.oneload
        call s:F.au.doevent("LoadPluginPre", plugname)
    endif
    "{{{4 Построение записи
    let entry={
                \        "status": ((has_key(a:regdict, "oneload") &&
                \                    a:regdict.oneload)?
                \                           ("loaded"):
                \                           ("registered")),
                \             "F": a:regdict.funcdict,
                \             "g": a:regdict.globdict,
                \      "scriptid": a:regdict.sid,
                \          "file": fnamemodify(a:regdict.scriptfile, ':p'),
                \  "extfunctions": [],
                \   "extcommands": [],
                \  "optionprefix": a:regdict.oprefix,
                \          "name": plugname,
                \    "quotedname": s:F.stuf.squote(plugname),
                \    "apiversion": map(split(matchstr(a:regdict.apiversion,
                \                                     '^\d\+\.\d\+'), '\.'),
                \                      'v:val+0'),
                \"globalmappings": {},
                \"buffermappings": {},
                \      "requires": {},
                \"requnsatisfied": {},
                \    "requiredby": {},
            \}
    if exists('*fnameescape')
        let entry.srccmd="source ".fnameescape(entry.file)
    else
        let entry.srccmd="source ".escape(entry.file, " \t\n*$`?[{\\%#'\"|!<")
    endif
    if has_key(s:g.reg.required, plugname)
        let entry.requiredby=s:g.reg.required[plugname]
        unlet s:g.reg.required[plugname]
    endif
    for regdictkey in s:g.reg.mapdict
        if has_key(a:regdict, regdictkey)
            let entry[regdictkey]=a:regdict[regdictkey]
        endif
    endfor
    if has_key(a:regdict, "requires")
        for [rplugname, rplugversion] in a:regdict.requires
            let entry.requires[rplugname]=map(
                        \                 split(
                        \                  matchstr(rplugversion,
                        \                           '^\d\+\(\.\d\+\)\='),
                        \                       '\.'), 'v:val+0')
            let entry.requnsatisfied[rplugname]=1
        endfor
    endif
    let entry.intfuncprefix='s:g.reg.registered['.entry.quotedname.'].F'
    let locks={}
    call map(["F", "g"], 'extend(locks, {(v:val): islocked("entry.".v:val)})')
    lockvar 1 entry
    for  v  in  ["status", "extfunctions", "extcommands", "g", "F",
                \"globalmappings", "buffermappings", "requiredby"]
        if !(has_key(locks, v) && locks[v])
            unlockvar entry[v]
        endif
    endfor
    let s:g.reg.registered[plugname]=entry
    let s:g.reg.plugsids[plugname]=a:regdict.sid
    "{{{4 Создание функций
    let F={}
    for fname in keys(s:F.cons)
        execute      "function F.".fname."(...)\n".
                    \"    return call(s:F.cons.".fname.", ".
                    \"             [s:g.reg.registered[".entry.quotedname."]]+".
                    \"             a:000, {})\n".
                    \"endfunction"
        let fnr=matchstr(string(F[fname]), '\d\+')
        let s:g.reg.unnamedfunctions[fnr]="cons:/".plugname."/".fname
    endfor
    "{{{4 Создание привязок
    if has_key(entry, "mappings")
        call s:F.maps.create(entry)
    endif
    "}}}4
    call s:F.comm.cf(entry)
    "{{{4 au RegisterPluginPost
    call s:F.au.doevent("RegisterPluginPost", plugname)
    "}}}4
    return      {     "name": plugname,
                \"functions": F}
endfunction
"{{{4 Проверки аргументов
"{{{5 Проверка для command
let s:g.c.comdict=[[["equal", "nargs" ],   ["or", [["in", ['*',
            \                                                '?',
            \                                                '+',
            \                                                '0']],
            \                                        ["regex",
            \                                          '^[1-9][0-9]*$']]]],
            \        [["equal", "range" ],   ["or", [["in", ['', '%']],
            \                                        ["regex",
            \                                          '^[1-9][0-9]*$']]]],
            \        [["equal", "count" ],   ["regex",
            \                                      '^\([1-9][0-9]*\)\=$']],
            \        [["equal", "bang"  ],   ["equal", ""]],
            \        [["equal", "reg"   ],   ["equal", ""]],
            \        [["equal", "bar"   ],   ["equal", ""]],
            \        [["equal", "complete"], ["or", [["in", ["augroup",
            \                                                "buffer",
            \                                                "command",
            \                                                "dir",
            \                                                "enviroment",
            \                                                "event",
            \                                                "expression",
            \                                                "file",
            \                                                "shellcmd",
            \                                                "function",
            \                                                "help",
            \                                                "highlight",
            \                                                "mapping",
            \                                                "menu",
            \                                                "option",
            \                                                "tag",
            \                                                "tag_listfiles",
            \                                                "var"]],
            \                                        ["regex",
            \                                 '^custom\(list\)\=,s:.*']]]],
            \        [["equal", "func"], ["regex", s:g.c.reg.rf]]]
"{{{5 s:g.c.register
let s:g.c.intmaps=["dict", [[["regex", '^\(+\)\@!'],
            \                  ["and", [["hkey", "function"],
            \                           ["dict", [[["equal", "function"],
            \                                      ["regex", s:g.c.reg.rf]],
            \                                     [["equal", "default"],
            \                                      ["type", type("")]],
            \                                     [["equal", "silent"],
            \                                      ["bool", ""]],
            \                                     [["equal", "leader"],
            \                                      ["bool", ""]],
            \                                     [["equal", "type"],
            \                                      ["in", [" ", "n", "v", "x",
            \                                              "s", "o", "!", "i",
            \                                              "l", "c"]]]]]]]]]]
let s:g.c.register=["and", [
            \["map", ["hkey", ["oprefix",
            \                  "funcdict",
            \                  "globdict",
            \                  "sid",
            \                  "scriptfile",
            \                  "apiversion",]]],
            \["allorno", [["hkey", "fprefix"],
            \             ["hkey", "functions"]]],
            \["allorno", [["hkey", "cprefix"],
            \             ["hkey", "commands"]]],
            \["dict", [
            \   [["equal", "dictfunctions"],
            \             ["alllst", ["chklst", [["type", type("")],
            \                                    ["regex", s:g.c.reg.rf],
            \                                    ["type",  type({})]]]]],
            \   [["equal", "fprefix"],  ["regex", s:g.c.reg.func]],
            \   [["equal", "cprefix"],  ["regex", s:g.c.reg.cmd]],
            \   [["equal", "oprefix"],  ["regex", s:g.c.reg.tf]],
            \   [["equal", "funcdict"], [ "type", type({})]],
            \   [["equal", "globdict"], [ "type", type({})]],
            \   [["equal", "commands"], [ "dict", [[["type", type("")],
            \                                       ["dict", s:g.c.comdict]]]]
            \   ],
            \   [["equal", "functions"],["alllst", ["chklst", [
            \                                         ["regex", s:g.c.reg.tf],
            \                                         ["regex", s:g.c.reg.rf],
            \                                         ["type",  type({})]]]]],
            \   [["equal", "mappings"], s:g.c.intmaps],
            \   [["equal", "oneload"],  ["bool", ""]],
            \   [["equal", "sid"],      ["regex", '^[1-9][0-9]*$']],
            \   [["equal", "scriptfile"], ["and", [["file", "r"],
            \                                      ["regex", '\.vim$']]]],
            \   [["equal", "apiversion"], ["regex", '^\d\+\.\d\+']],
            \   [["equal", "requires"],   ["alllst", ["chklst", [["any", ""],
            \                                                    ["regex",
            \                                                     '^\d\+']]]]],
            \   [["equal", "leader"],     ["type", type("")]],
            \   [["any", ''], ["any", '']],
            \ ]
            \],
        \]]
"{{{3 reg.unreg:     Удалить команды и функции
function s:F.reg.unreg(plugname)
    let plugdict=s:g.reg.registered[a:plugname]
    for f in plugdict.extfunctions
        execute "delfunction ".f
    endfor
    for c in plugdict.extcommands
        execute "delcommand ".c
    endfor
    unlet s:g.reg.registered[a:plugname]
    unlet plugdict
endfunction
"{{{2 maps: create, delmappings
"{{{3 autocommands
augroup LoadDeleteBufferMappings
    autocmd!
    autocmd BufWipeout * call s:F.maps.delmappings(expand("<abuf>"))
augroup END
augroup LoadNewBuffer
    autocmd!
    autocmd BufAdd * call s:F.maps.newbuffer(expand("<abuf>"))
augroup END
"{{{3 s:g.maps
let s:g.maps={}
let s:g.maps.created_buffer={}
let s:g.maps.created_global={}
let s:g.maps.bufmaps=[]
let s:g.maps.mapcommands={
            \" ": "noremap",
            \"!": "noremap!",
        \}
call map(["n", "v", "x", "s", "o", "i", "l", "c"],
            \'extend(s:g.maps.mapcommands, {(v:val): (v:val."noremap")})')
lockvar 1 s:g.maps
"{{{3 maps.map
function s:F.maps.map(plugdict, mapname, options, mapstring, buffer)
    let selfname="maps.map"
    "{{{4 Пустая строка
    if a:mapstring==#""
        return 1
    endif
    "{{{4 mapoptions
    if !has_key(a:options, a:mapname)
        return s:F.main.eerror(selfname, "option", ["ukmap", a:mapname,
                    \                               a:plugdict.name])
    endif
    let mapoptions=a:options[a:mapname]
    "{{{4 Тип привязки: определение команды
    let type=" "
    if has_key(mapoptions, "type")
        let type=mapoptions.type
    endif
    "{{{4 Проверка существования привязки
    if a:buffer
        let curbuffer=bufnr("%")
        if           has_key(s:g.maps.created_buffer,curbuffer) &&
                    \has_key(s:g.maps.created_buffer[curbuffer],type) &&
                    \has_key(s:g.maps.created_buffer[curbuffer][type],
                    \        a:mapstring)
            return s:F.main.eerror(selfname, "perm", ["ebmap", a:mapstring,
                        \s:g.maps.created_buffer[curbuffer][type][a:mapstring]
                        \[0]])
        endif
    else
        if           has_key(s:g.maps.created_global,type) &&
                    \has_key(s:g.maps.created_global[type], a:mapstring)
            return s:F.main.eerror(selfname, "perm", ["egmap", a:mapstring,
                        \s:g.maps.created_global[type][a:mapstring][0]])
        endif
    endif
    let cmd=s:g.maps.mapcommands[type]
    let mapcommand=cmd." <special> <expr> "
    "{{{4 <buffer>
    if a:buffer
        let mapcommand.="<buffer> "
    endif
    "{{{4 <silent>
    if has_key(mapoptions, "silent") && mapoptions.silent
        let mapcommand.="<silent> "
    endif
    "{{{4 Основная часть команды
    let mapcommand.=s:F.stuf.mapprepare(a:mapstring)." "
    let mapcommand.='call(<SID>Eval("s:F.maps.run"), ['.
                \"'".type."', ".
                \s:F.stuf.mapprepare(s:F.stuf.squote(a:mapstring)).", ".
                \((a:buffer)?(bufnr("%")):(-1)).
                \'], {})'
    "{{{4 Создание привязки, обработка ошибок
    try
        execute mapcommand
        "{{{5 Создание записи о созданной привязке
        if a:buffer
            let curbuffer=bufnr("%")
            if !has_key(s:g.maps.created_buffer, curbuffer)
                let s:g.maps.created_buffer[curbuffer]={}
            endif
            let created=s:g.maps.created_buffer[curbuffer]
            if !has_key(a:plugdict.buffermappings, curbuffer)
                let a:plugdict.buffermappings[curbuffer]={}
            endif
            let created_plugin=a:plugdict.buffermappings[curbuffer]
        else
            let created=s:g.maps.created_global
            let created_plugin=a:plugdict.globalmappings
        endif
        if !has_key(created, type)
            let created[type]={}
        endif
        if !has_key(created_plugin, type)
            let created_plugin[type]={}
        endif
        let centry=[a:plugdict.name, a:mapname, copy(mapoptions)]
        let created[type][a:mapstring]=centry
        let created_plugin[type][a:mapstring]=centry
        "}}}5
        return 1
    catch
        return s:F.main.eerror(selfname, "ofail", v:exception)
    endtry
    "}}}4
endfunction
"{{{3 maps.create
function s:F.maps.create(plugdict)
    "{{{4 Объявление переменных
    let selfname="maps.create"
    let [bmaps, gmaps, options]=s:F.cons.option(a:plugdict, "_maps")
    if options=={} || s:F.cons.option(a:plugdict, "_disablemaps")
        return 0
    endif
    let leader=s:F.cons.option(a:plugdict, "_leader")
    "{{{4 Добавление локальных привязок
    for [mapname, mapstring] in items(bmaps)
        let mapname=substitute(mapname, '^{-.\{-}-}', '', '')
        if mapname[0]==#'+'
            let mapname=mapname[1:]
            let mapstring=leader.mapstring
        endif
        call s:F.maps.map(mapname, options, mapstring, 1)
    endfor
    "{{{4 Добавление глобальных привязок
    for [mapname, mapstring] in items(gmaps)
        let mapname=substitute(mapname, '^{-.\{-}-}', '', '')
        if mapname[0]==#'+'
            let mapname=mapname[1:]
            let mapstring=leader.mapstring
        endif
        call s:F.maps.map(a:plugdict, mapname, options, mapstring, 0)
    endfor
    for [mapname, mapoptions] in items(options)
        if !has_key(gmaps, mapname) && has_key(mapoptions, "default")
            let mapstring=mapoptions.default
            if has_key(mapoptions, "leader") && mapoptions.leader
                let mapstring=leader.mapstring
            endif
            call s:F.maps.map(a:plugdict, mapname, options, mapstring, 0)
        endif
    endfor
    "}}}4
    return 1
endfunction
"{{{3 maps.run
function s:F.maps.run(type, mapstring, buffer)
    if a:buffer==-1
        let [plugname, mapname, mapoptions]=
                    \             s:g.maps.created_global[a:type][a:mapstring]
    else
        let [plugname, mapname, mapoptions]=
                    \   s:g.maps.created_buffer[a:buffer][a:type][a:mapstring]
    endif
    let plugdict=s:F.comm.getpldict(plugname)
    if plugdict.status!=#"loaded"
        call s:F.comm.load(plugname)
    endif
    return call(eval("plugdict.F.".(mapoptions.function)),
                \[a:type, mapname, a:mapstring, a:buffer], {})
endfunction
"{{{3 maps.unmap
function s:F.maps.unmap(plugname, mapname, mapoptions, mapstring, buffer)
    let selfname='maps.unmap'
    let type=" "
    if has_key(a:mapoptions, "type")
        let type=a:mapoptions.type
    endif
    let unmapcommand=substitute(s:g.maps.mapcommands[type], 'nore', 'un', '').
                \" <special> ".((a:buffer!=-1)?("<buffer> "):("")).
                \s:F.stuf.mapprepare(a:mapstring)
    try
        execute unmapcommand
        if a:buffer==-1
            unlet s:g.reg.registered[a:plugname].globalmappings
                        \[type][a:mapstring]
            unlet s:g.maps.created_global[type][a:mapstring]
        else
            unlet s:g.reg.registered[a:plugname].buffermappings[a:buffer]
                        \[type][a:mapstring]
            unlet s:g.maps.created_buffer[a:buffer][type][a:mapstring]
        endif
        return 1
    catch
        return s:F.main.eerror(selfname, "ofail", v:exception)
    endtry
endfunction
"{{{3 maps.delmappings
function s:F.maps.delmappings(what)
    "{{{4 Удаление привязок, связанных с текущим буфером
    if type(a:what)==type(0) && has_key(s:g.maps.created_buffer, a:what)
        for [type, mappings] in items(s:g.maps.created_buffer[a:what])
            for [mapstring, centry] in items(mappings)
                call call(s:F.maps.unmap, centry+[mapstring, a:what], {})
            endfor
            unlet s:g.maps.created_buffer[a:what][type]
        endfor
        unlet s:g.maps.created_buffer[a:what]
    "{{{4 Удаление привязок указанного дополнения
    elseif type(a:what)==type({})
        "{{{5 Удаление локальных привязок
        if has_key(a:what, "buffermappings")
            let savedbufnr=bufnr("%")
            let savedhidden=&hidden
            let savedbufhidden={}
            set hidden
            for [buffer, m] in items(a:what.buffermappings)
                let sbh=getbufvar(buffer, '&bufhidden')
                if index(["", "hide"], sbh)==-1
                    let savedbufhidden[buffer]=sbh
                    setlocal bufhidden=
                endif
                execute "buffer ".buffer
                for [type, mappings] in items(m)
                    for [mapstring, centry] in items(mappings)
                        call call(s:F.maps.unmap, centry+[mapstring, buffer],
                                    \{})
                    endfor
                endfor
            endfor
            execute "buffer ".savedbufnr
            call map(savedbufhidden, 'setbufvar(v:key, v:val)')
            let &hidden=savedhidden
        endif
        "{{{5 Удаление глобальных привязок
        if has_key(a:what, "globalmappings")
            for [type, mappings] in items(a:what.globalmappings)
                for [mapstring, centry] in items(mappings)
                    call call(s:F.maps.unmap, centry+[mapstring, -1], {})
                endfor
            endfor
        endif
        "}}}5
    endif
    "}}}4
    return 1
endfunction
"{{{3 maps.newbuffer
function s:F.maps.newbuffer(buffer)
    for plugdict in values(s:g.reg.registered)
        let [bmaps, gmaps, options]=s:F.cons.option(plugdict, "_maps")
        if options=={}
            continue
        endif
        let leader=s:F.cons.option(plugdict, "_leader")
        for [mapname, mapstring] in items(bmaps)
            let mapname=substitute(mapname, '^{-.\{-}-}', '', '')
            if mapname[0]==#'+'
                let mapname=mapname[1:]
                let mapstring=leader.mapstring
            endif
            call s:F.maps.map(mapname, options, mapstring, 1)
        endfor
    endfor
    return 1
endfunction
"{{{2 comm: load, cf, getfunctions, lazyload, unload
"{{{3 s:g.comm
let s:g.comm={}
"{{{3 comm.cmdadd:       Создать команду
function s:F.comm.cmdadd(key, value, cmdargs, plugdict, command)
    "{{{4 Объявление переменных
    let result='-'.a:key
    let append=""
    "{{{4 Автодополнение
    if a:key==#"complete" && a:value=~'^custom'
        "{{{5 Объявление переменных
        let plugname=a:plugdict.quotedname
        " -complete=custom,func или -complete=customlist,func
        let funcname=matchstr(a:value, 'custom\(list\)\=,\zss:.*')
        " удаляем s:
        let intfunc=funcname[2:]
        let quotedintfunc="'".substitute(intfunc, "'", "''", "g")."'"
        " имя функции внутри дополнения (s:F.comp.funcname)
        let intfuncname=(a:plugdict.intfuncprefix).'.comp['.quotedintfunc.']'
        " чтобы функции к разным командам не пересекались добавим имя команды 
        " к имени функции
        let realname=funcname.(a:command)
        let append=a:command
        " шаблон для автокоманды
        " // Vim 7.2: starts with P<scriptid>
        " // Vim 7.3: starts with R<scriptid> => removed P, not adding R
        let fpattern="*".(s:g.scriptid)."_".realname[2:]
        "{{{5 Если дополнение загружено
        if a:plugdict.status==#"loaded"
            "{{{6 Создание функции
            if !exists("*".realname)
                execute      "function ".realname."(...)\n".
                            \"    silent! return call(".intfuncname.", ".
                            \                        "a:000, {})\n".
                            \"endfunction"
            endif
            call add(a:plugdict.extfunctions, realname)
            "{{{6 Удаление автокоманды
            augroup LoadBeforeLoadComp
                execute "autocmd! FuncUndefined ".fpattern
            augroup END
        "{{{5 Если нет
        else
            augroup LoadBeforeLoadComp
                execute "autocmd! FuncUndefined ".fpattern
                execute "autocmd FuncUndefined ".fpattern." ".
                            \"call s:F.comm.load(".plugname.")"
            augroup END
        endif
        "}}}5
    endif
    "}}}4
    if a:value!=""
        let result.='='.a:value.append
    endif
    call add(a:cmdargs, result)
    return result
endfunction
"{{{3 comm.mkcmd:        Создать команду
function s:F.comm.mkcmd(cmd, plugdict)
    let selfname="comm.mkcmd"
    "{{{4 Объявление переменных
    let cmdargs=[]
    let fargs=[]
    let plugname=a:plugdict.quotedname
    let intfuncprefix=a:plugdict.intfuncprefix
    let cmddescr=a:plugdict.commands[a:cmd]
    let cmd=s:F.cons.option(a:plugdict, '_cprefix').a:cmd
    let loadcmd="call s:F.comm.load(".plugname.")"
    "{{{4 Получение ключей для :command
    for key in keys(cmddescr)
        if has_key(s:g.comm.cmdfargs, key)
            call s:F.comm.cmdadd(key, cmddescr[key], cmdargs, a:plugdict, cmd)
            if s:g.comm.cmdfargs[key]!=""
                call add(fargs, s:g.comm.cmdfargs[key])
            endif
        endif
    endfor
    "{{{4 Удаление старой команды
    if exists(':'.cmd)
        if index(a:plugdict.extcommands, cmd)!=-1
            execute "delcommand ".cmd
        else
            return s:F.main.eerror(selfname, "perm", ["cexst", a:plugdict.name,
                        \                             cmd])
        endif
    endif
    "{{{4 Создание команды
    execute "command ".join(cmdargs, " ")." ".cmd." ".
                \((a:plugdict.status==#"loaded")?(""):(loadcmd." | ")).
                \"call ".(intfuncprefix.".".(cmddescr.func)).
                \"(".join(sort(fargs), ", ").")"
    "{{{4 Регистрация команды
    if a:plugdict.status==#"registered"
        call add(a:plugdict.extcommands, cmd)
    endif
    return 1
    "}}}4
endfunction
"{{{4 Аргументы для command
" Порядок аргументов будет (благодаря сортировке по алфавиту):
"   "'<bang>'", "'<reg>'", "<LINE1>, <LINE2>", "<count>", "<f-args>"
let s:g.comm.cmdfargs={
            \   "nargs": "<f-args>",
            \   "range": "<LINE1>, <LINE2>",
            \   "count": "<count>",
            \    "bang": "'<bang>'",
            \     "reg": "'<reg>'",
            \  "buffer": "",
            \"complete": ""
        \}
lockvar! s:g.comm.cmdfargs
"{{{3 comm.getcheck:     Создать строку проверки для аргументов функции
function s:F.comm.getcheck(check, checkstr)
    if len(keys(a:check))
        return "let args=s:F.plug.chk.checkarguments(".a:checkstr.", a:000)\n".
                    \"if type(args)!=type([])\n".
                    \"throw 'checkFailed'\n".
                    \"endif\n"
    endif
    return "let args=a:000\n"
endfunction
"{{{3 comm.mkfuncs
" Создать функции или события FuncUndefined. Событие создаётся, если 
" plugdict.status!="loaded"
function s:F.comm.mkfuncs(plugdict)
    let selfname='comm.mkfuncs'
    if !has_key(a:plugdict, "functions")
        return 0
    endif
    let plugname=a:plugdict.quotedname
    let loadcmd="call s:F.comm.load(".plugname.")"
    let i=0
    for [extname, intname, acheck] in a:plugdict.functions
        let intfuncprefix=a:plugdict.intfuncprefix
        let extname=s:F.cons.option(a:plugdict, '_fprefix').extname
        if exists('*'.extname)
            call s:F.main.eerror(selfname, "perm", ["fexst", a:plugdict.name,
                        \                           extname])
            continue
        endif
        let checkstr='s:g.reg.registered['.plugname.'].functions['.i.'][2]'
        let check=s:F.comm.getcheck(acheck, checkstr)
        if a:plugdict.status==#"loaded"
            execute      "function ".extname."(...)\n".
                        \     (check).
                        \"    return call(".intfuncprefix.".".intname.", ".
                        \           "args, s:F)\n"
                        \"endfunction"
            call add(a:plugdict.extfunctions, extname)
        else
            augroup LoadBeforeLoad
                execute "autocmd! FuncUndefined ".extname
                execute "autocmd FuncUndefined ".extname." ".loadcmd
            augroup END
        endif
        let i+=1
    endfor
    return 1
endfunction
"{{{3 comm.load:         Загрузить плагин
function s:F.comm.load(plugname)
    let selfname='comm.load'
    call s:F.au.doevent("LoadPluginPre", a:plugname)
    let plugdict=s:F.comm.getpldict(a:plugname)
    if plugdict.status==#"loaded"
        return 1
    endif
    execute plugdict.srccmd
    let plugdict.status="loaded"
    call s:F.comm.cf(plugdict)
    if plugdict.requnsatisfied!={}
        return s:F.main.eerror(selfname, "req", ["nreq", a:plugname],
                    \          join(keys(plugdict.requnsatisfied)))
    endif
    "{{{4 Ленивая загрузка
    if has_key(s:g.reg.lazyload, a:plugname)
        while !empty(s:g.reg.lazyload[a:plugname])
            unlockvar! s:g.reg.lazyload[a:plugname][-1]
            unlet s:g.reg.lazyload[a:plugname][-1]._plugname
            unlet s:g.reg.lazyload[a:plugname][-1]._position
            call extend(s:g.reg.lazyload[a:plugname][-1],
                        \s:F.comm.cdict(plugdict))
            unlet s:g.reg.lazyload[a:plugname][-1]
        endwhile
    endif
    "}}}4
    call s:F.au.doevent("LoadPluginPost", a:plugname)
    return 1
endfunction
"{{{3 comm.cdict:        Создать словарь с функциями
function s:F.comm.cdict(plugdict)
    if !has_key(a:plugdict, "dictfunctions")
        return {}
    endif
    let plugname=a:plugdict.quotedname
    let intfuncprefix=a:plugdict.intfuncprefix
    let r={}
    let i=0
    for [dictname, intname, acheck] in a:plugdict.dictfunctions
        let checkstr='s:g.reg.registered['.plugname.'].dictfunctions['.i.'][2]'
        let check=s:F.comm.getcheck(acheck, checkstr)
        execute      "function r.".dictname."(...)\n".
                    \(check).
                    \"    return call(".intfuncprefix.".".intname.", ".
                    \                 "args, {})\n".
                    \"endfunction"
        let fnr=matchstr(string(r[dictname]), '\d\+')
        let s:g.reg.unnamedfunctions[fnr]="dict:/".(a:plugdict.name)."/".
                    \dictname." -> /".(a:plugdict.name)."/".
                    \tr(intname, '.', '/')
        let i+=1
    endfor
    return r
endfunction
"{{{3 comm.cf:           Создать команды и функции
function s:F.comm.cf(plugdict)
    for [rplugname, rplugversion] in items(a:plugdict.requires)
        call s:F.comm.loadreq(a:plugdict, rplugname, rplugversion)
    endfor
    if has_key(a:plugdict, "commands")
        call map(keys(a:plugdict.commands), 's:F.comm.mkcmd(v:val, a:plugdict)')
    endif
    call s:F.comm.mkfuncs(a:plugdict)
endfunction
"{{{3 comm.loadreq:      Загрузить требуемое дополнение
function s:F.comm.loadreq(plugdict, rplugname, rplugversion)
    let selfname='comm.loadreq'
    let rplugdict={}
    if !has_key(s:g.reg.registered, a:rplugname)
        if !has_key(s:g.reg.required, a:rplugname)
            let s:g.reg.required[a:rplugname]={}
        endif
        let s:g.reg.required[a:rplugname][a:plugdict.name]=1
        if a:plugdict.status==#"loaded"
            let rplugdict=s:F.comm.getpldict(a:rplugname, 0)
        endif
    else
        let rplugdict=s:g.reg.registered[a:rplugname]
    endif
    if rplugdict!={}
        if rplugdict.apiversion[0]!=a:rplugversion[0]
            return s:F.main.eerror(selfname, "req", 1, ["majap",
                        \          a:rplugname, a:plugdict.name,
                        \          rplugdict.apiversion[0],
                        \          a:rplugversion[0]])
        elseif len(a:rplugversion)>1 &&
                    \rplugdict.apiversion[1]<a:rplugversion[1]
            return s:F.main.eerror(selfname, "req", 1, ["minap",
                        \          a:rplugname, a:plugdict.name,
                        \          rplugdict.apiversion[1],
                        \          a:rplugversion[1]])
        elseif !has_key(rplugdict.requiredby, a:plugdict.name)
            let rplugdict.requiredby[a:plugdict.name]=1
        endif
        if a:plugdict.status==#"loaded"
            if rplugdict.status!=#"loaded"
                call s:F.comm.load(a:rplugname)
            endif
            if rplugdict.status==#"loaded" && has_key(a:plugdict.requnsatisfied,
                        \                             a:rplugname)
                unlet a:plugdict.requnsatisfied[a:rplugname]
            endif
        endif
    elseif a:plugdict.status==#"loaded"
        return s:F.main.eerror(selfname, "req", 0, ["nplug", a:rplugname])
    endif
endfunction
"{{{3 comm.getpldict:    Получить словарь, связанный с плагином
function s:F.comm.getpldict(plugname, ...)
    let selfname="comm.getpldict"
    if !has_key(s:g.reg.registered, a:plugname)
        execute "runtime plugin/".a:plugname.".vim"
    endif
    if !has_key(s:g.reg.registered, a:plugname)
        return s:F.main.eerror(selfname, "value", (a:000==[]),
                    \          ["nplug", a:plugname])
    endif
    return s:g.reg.registered[a:plugname]
endfunction
"{{{3 comm.getfunctions: Получить функции плагина
function s:F.comm.getfunctions(plugname)
    let selfname="comm.getfunctions"
    let plugdict=s:F.comm.getpldict(a:plugname)
    if plugdict.status!=#"loaded"
        call s:F.comm.load(a:plugname)
    endif
    return s:F.comm.cdict(plugdict)
endfunction
"{{{3 comm.lazyload:
function s:F.comm.lazyload(plugname)
    let selfname="comm.lazyload"
    if !has_key(s:g.reg.registered, a:plugname) ||
                \s:g.reg.registered[a:plugname].status!=#"loaded"
        if !has_key(s:g.reg.lazyload, a:plugname)
            let s:g.reg.lazyload[a:plugname]=[]
        endif
        let result={"_plugname": a:plugname,
                    \"_position": len(s:g.reg.lazyload[a:plugname])}
        lockvar! result
        call add(s:g.reg.lazyload[a:plugname], result)
        return result
    else
        return s:F.comm.cdict(s:g.reg.registered[a:plugname])
    endif
endfunction
"{{{3 comm.run:          Запустить функцию из «лениво» созданного словаря
function s:F.comm.run(lazydict, funcname, ...)
    let selfname="comm.run"
    if type(a:lazydict)!=type({})
        return s:F.main.eerror(selfname, "syntax", ["1dict"])
    elseif type(a:funcname)!=type("")
        return s:F.main.eerror(selfname, "syntax", ["2str"])
    endif
    if has_key(a:lazydict, "_plugname") &&
                \type(a:lazydict._plugname)==type("") &&
                \has_key(s:g.reg.lazyload, a:lazydict._plugname) &&
                \has_key(a:lazydict, "_position") &&
                \type(a:lazydict._position)==type(0) &&
                \s:g.reg.lazyload[a:lazydict._plugname][a:lazydict._position] is
                \                                                     a:lazydict
        if !s:F.comm.load(a:lazydict._plugname)
            return s:F.main.eerror(selfname, "nfnd", 1,
                        \          ["nplug", a:lazydict._plugname])
        endif
    endif
    if has_key(a:lazydict, a:funcname)
        return call(a:lazydict[a:funcname], a:000, a:lazydict)
    else
        return s:F.main.eerror(selfname, "nfnd", 1, ["nfunc", a:funcname])
    endif
endfunction
"{{{3 comm.rdict:        Вернуть словарь с функциями данного плагина
function s:F.comm.rdict()
    return s:F.comm.cdict(s:g.reg.registered.load)
endfunction
let s:g.c.tstr={
            \"model": "simple",
            \"required": [["type", type("")]]
        \}
lockvar! s:g.c.tstr
let s:g.comm.f=[
            \["registerplugin",   "reg.register", {}],
            \["unregister",       "reg.unreg",
            \                   {"model": "simple",
            \                    "required": [["keyof", s:g.reg.registered]]}],
            \["getfunctions",     "comm.getfunctions", s:g.c.tstr],
            \["lazygetfunctions", "comm.lazyload",     s:g.c.tstr],
            \["run",              "comm.run",          {}],
            \["restoresession", "ses.restore", {"model": "simple",
            \                                "required": [["file", 'r']]}],
        \]
lockvar! s:g.comm
unlockvar! s:g.reg.registered
"{{{3 comm.getdep:       Получить список зависимостей (для удаления)
function s:F.comm.getdep(plugdict, hasdep)
    let r=[a:plugdict]
    for plugname in keys(a:plugdict.requiredby)
        if !has_key(a:hasdep, plugname)
            let a:hasdep[plugname]=1
            call extend(r, s:F.comm.getdep(s:F.comm.getpldict(plugname),
                        \                  a:hasdep))
        endif
    endfor
    return r
endfunction
"{{{3 comm.depcomp:      Сравнить количество зависимых плагинов
function s:DepComp(plugdict1, plugdict2)
    let depnum1=len(keys(a:plugdict1.requiredby))
    let depnum2=len(keys(a:plugdict2.requiredby))
    return ((depnum1>depnum2)?
                \(1):
                \((depnum1<depnum2)?
                \   (-1):
                \   (0)))
endfunction
let s:F.int["s:DepComp"]=function("s:DepComp")
let s:F.comm.depcomp=function("s:DepComp")
"{{{3 comm.unload:       Удалить плагин
function s:F.comm.unload(plugname)
    let plugdict=s:g.reg.registered[a:plugname]
    call s:F.au.doevent("UnloadPluginPre", a:plugname)
    let srccmd=""
    let hasdep={}
    let depends=sort(s:F.comm.getdep(plugdict, hasdep), s:F.comm.depcomp)
    let plugins=filter(copy(depends), 'v:val.requiredby=={}')
    let plugnames=map(copy(plugins), 'v:val.name')
    call filter(depends, 'v:val.requiredby!={}')
    while depends!=[]
        let removedsmth=0
        let i=0
        while i<len(depends)
            if filter(keys(depends[i].requiredby),
                        \'index(plugnames, v:val)==-1')==[]
                call add(plugins, depends[i])
                call add(plugnames, depends[i].name)
                call remove(depends, i)
                let removedsmth=1
            else
                let i+=1
            endif
        endwhile
        if !removedsmth && depends!=[]
            call add(plugins, depends[0])
            call add(plugnames, depends[0].name)
            call remove(depends, 0)
            continue
        endif
    endwhile
    for plugdict in plugins
        if plugdict.status!=#'loaded'
            call s:F.comm.load(plugdict.name)
        endif
    endfor
    let srccmd=join(map(reverse(copy(plugins)), 'v:val.srccmd'), "\n")
    for plugdict in plugins
        if has_key(plugdict, "mappings")
            call s:F.maps.delmappings(plugdict)
        endif
        call s:F.reg.unreg(plugdict.name)
        if has_key(plugdict.F, "main") && has_key(plugdict.F.main, "destruct")
            call plugdict.F.main.destruct()
        endif
        unlockvar plugdict.g
        unlockvar plugdict.F
        for key in keys(plugdict.g)
            unlet plugdict.g[key]
        endfor
        for key in keys(plugdict.F)
            unlet plugdict.F[key]
        endfor
        unlet plugdict.g
        unlet plugdict.F
    endfor
    call s:F.au.doevent("UnloadPluginPost", a:plugname)
    return srccmd
endfunction
"{{{2 au: regevent, delevent, doau
"{{{3 s:g.au
let s:g.au={}
let s:g.au.events={}
let s:g.au.events.RegisterPluginPre={}
let s:g.au.events.LoadPluginPre={}
let s:g.au.events.UnloadPluginPre={}
let s:g.au.events.RegisterPluginPost={}
let s:g.au.events.LoadPluginPost={}
let s:g.au.events.UnloadPluginPost={}
lockvar 1 s:g.au
lockvar 1 s:g.au.events
"{{{3 au.doau
function s:F.au.doau(Command, event, plugin)
    if type(a:Command)==type("")
        execute a:Command
    else
        call call(a:Command, [a:event, a:plugin], {})
    endif
endfunction
"{{{3 au.doevent
function s:F.au.doevent(event, plugin)
    for l:Cmd in get(s:g.au.events[a:event], a:plugin, [])
        call s:F.au.doau(l:Cmd, a:event, a:plugin)
    endfor
endfunction
"{{{3 au.regevent
function s:F.au.regevent(event, plugin, Command)
    if !has_key(s:g.au.events[a:event], a:plugin)
        let s:g.au.events[a:event][a:plugin]=[]
    endif
    call add(s:g.au.events[a:event][a:plugin], a:Command)
endfunction
"{{{3 au.delevent
function s:F.au.delevent(event, plugin, Command)
    if type(a:Command)!=type(0)
        if !has_key(s:g.au.events[a:event], a:plugin)
            return
        endif
        call filter(s:g.au.events[a:event][a:plugin],
                    \'!(type(v:val)==type(a:Command) && v:val==#a:Command)')
    elseif type(a:plugin)==type("")
        call filter(s:g.au.events[a:event], 'v:key!=#a:plugin')
        if !empty(s:g.au.events[a:event])
            call remove(s:g.au.events[a:event], 0, -1)
        endif
    else
        for key in keys(s:g.au.events[a:event])
            unlet s:g.au.events[a:event][key]
        endfor
    endif
endfunction
"{{{3 s:g.comm.f
unlockvar 1 s:g.comm.f
call add(s:g.comm.f,
            \["autocmd", 'au.regevent', {"model": "simple",
            \                         "required": [["keyof", s:g.au.events],
            \                                      ["type", type("")],
            \                                      ["type", type("")]]}])
call add(s:g.comm.f,
            \["delautocmd", 'au.delevent',
            \           {"model": "optional",
            \         "required": [["keyof", s:g.au.events]],
            \         "optional": [[["type", type("")], {}, ""],
            \                      [["type", type("")], {}, ""]]}])
lockvar 2 s:g.comm.f
"{{{2 ses: mksession, loadsession
"{{{3 ses.mksession
function s:F.ses.mksession(sfile)
    let selfname='ses.mksession'
    try
        execute "mksession! ".fnameescape(a:sfile)
    catch
        return s:F.main.eerror(selfname, "ofail", 1, ["sesnf"], v:exception)
    endtry
    let xfile=fnamemodify(a:sfile, ':p:r').'x.vim'
    if filewritable(fnamemodify(a:sfile, ':p:h'))==2
        if filereadable(xfile)
            if !filewritable(xfile)
                return s:F.main.eerror(selfname, "ofail", 1, ["sesfx", xfile])
            endif
            " let sescontent=readfile(xfile, 'b')
            let sescontent=[]
        else
            let sescontent=[]
        endif
        let sescontent+=[
                    \'call load#LoadFuncdict().getfunctions("load").'.
                    \           'restoresession(expand("<sfile>"))',
                    \'finish',
                    \'### YAML document starts here ###',
                    \]
        let plses={}
        for [plugname, plugdict] in items(s:g.reg.registered)
            if has_key(plugdict.F, "main") && has_key(plugdict.F.main,
                        \                            "session")
                let plses[plugname]=plugdict.F.main.session()
            endif
        endfor
        if !(has_key(s:g.reg.registered, "yaml") &&
                    \s:g.reg.registered.yaml.status==#"loaded")
            call s:F.comm.load("yaml")
        endif
        if !(has_key(s:g.reg.registered, "yaml") &&
                    \s:g.reg.registered.yaml.status==#"loaded")
            return s:F.main.eerror(selfname, "ofail", 1, ["yamlf"])
        endif
        call extend(sescontent, s:F.plug.yaml.dumps(plses, 0))
        call add(sescontent, "")
        call writefile(sescontent, xfile, 'b')
    else
        return s:F.main.eerror(selfname, "ofail", 1, ["sesdw",
                    \                             fnamemodify(a:sfile, ':p:h')])
    endif
endfunction
"{{{3 ses.restore
function s:F.ses.restore(sfile)
    let selfname='ses.restore'
    let sescontent=readfile(a:sfile, 'b')
    while sescontent[0]!=#'### YAML document starts here ###'
        call remove(sescontent, 0)
    endwhile
    if !(has_key(s:g.reg.registered, "yaml") &&
                \s:g.reg.registered.yaml.status==#"loaded")
        call s:F.comm.load("yaml")
    endif
    if !(has_key(s:g.reg.registered, "yaml") &&
                \s:g.reg.registered.yaml.status==#"loaded")
        return s:F.main.eerror(selfname, "ofail", 1, ["yamlf"])
    endif
    let plses=s:F.plug.yaml.loads(join(sescontent, "\n"))
    for [plugname, arg] in items(plses)
        let plugdict=s:F.comm.getpldict(plugname)
        if has_key(plugdict.F, "main") && has_key(plugdict.F.main,
                    \                            "session")
            call plugdict.F.main.session(arg)
        endif
        unlet arg
    endfor
endfunction
"{{{2 mng: main
"{{{3 mng.main
"{{{4 s:g.c.cmd
let s:g.c.nothing={"model": "optional"}
let s:g.c.cmd={
            \"model": "actions",
            \"actions": {}
        \}
let s:g.c.cmd.actions.unload={
            \   "model": "simple",
            \"required": [["keyof", s:g.reg.registered]]
        \}
let s:g.c.cmd.actions.reload=s:g.c.cmd.actions.unload
let s:g.c.cmd.actions.show=s:g.c.nothing
let s:g.c.cmd.actions.findnr={"model": "simple",
            \                "required": [["type", type("")]]}
let s:g.c.cmd.actions.nrof={"model": "simple",
            \              "required": [{"check": ["regex", '^/']}]}
let s:g.c.cmd.actions.autocmd={"model": "optional",
            \               "required": [["keyof", s:g.au.events],
            \                            ["type", type("")],
            \                            ["type", type("")]],
            \                   "next": ["type", type("")]}
let s:g.c.cmd.actions["autocmd!"]={"model": "optional",
            \                   "required": [["keyof", s:g.au.events]],
            \                   "optional": [[["keyof", s:g.reg.registered],
            \                                 {}, 0]],
            \                       "next": ["type", type("")]}
let s:g.c.cmd.actions.mksession={"model": "simple",
            \                 "required": [["file", "w"]]}
lockvar! s:g.c
unlockvar! s:g.reg.registered
for s:key in keys(s:g.au.events)
    execute "unlockvar! s:g.au.events.".s:key
endfor
unlet s:key
"}}}4
function s:F.mng.main(action, ...)
    "{{{4 Объявление переменных
    let selfname="mng.main"
    let action=tolower(a:action)
    "{{{4 Проверка ввода
    let args=s:F.plug.chk.checkarguments(s:g.c.cmd, [action]+a:000)
    if type(args)!=type([])
        return 0
    endif
    "{{{4 Действия
    "{{{5 Выгрузить дополнение
    if action==#"unload"
        return s:F.comm.unload(args[1])!=#""
    "{{{5 Перезагрузить дополнение
    elseif action==#"reload"
        execute s:F.comm.unload(args[1])
        return 1
    "{{{5 Показать список загруженных дополнений
    elseif action==#"show"
        let lines=values(map(copy(s:g.reg.registered),
                    \'[v:val.scriptid, v:key, v:val.file, v:val.status]'))
        return s:F.stuf.printtable(s:g.p.th, lines)
    "{{{5 Найти функцию, соответствующую номеру
    elseif action==#"findnr"
        let results=map(split(args[1], '\D\+'),
                    \'[v:val, s:F.stuf.findnr(v:val)]')
        call map(results,
                    \'[v:val[0], '.
                    \'((type(v:val[1])==type(""))?(v:val[1]):(s:g.p.nfnd))]')
        if len(results)==1
            echo results[0][1]
        else
            echo join(map(results, 'join(v:val, ": ")'), "\n")
        endif
        return 1
    "{{{5 Найти номер, соответствующий функции
    elseif action==#"nrof"
        let Result=s:F.stuf.findpath(args[1])
        if type(Result)==2
            echo Result
            return 1
        elseif type(Result)==type({})
            let list=s:F.stuf.fdictstr(Result, 0)
            call map(list, '[repeat(" ", v:val[0]).v:val[1], '.
                        \"substitute(s:F.stuf.string(v:val[2]), ".
                        \                   "'^.*''\\([^'']*\\)''.*$', ".
                        \                   "'\\1', '')]")
            return s:F.stuf.printtable([], list)
        else
            echo s:g.p.nfnd
        endif
    "{{{5 autocmd
    elseif action==#"autocmd"
        call s:F.au.regevent(args[1], args[2], join(args[3:]))
    "{{{5 autocmd!
    elseif action==#"autocmd!"
        call s:F.au.delevent(args[1], args[2],
                    \((len(args)>2)?
                    \   (join(args[3:])):
                    \   (0)))
    "{{{5 mksession
    elseif action==#"mksession"
        call s:F.ses.mksession(args[1])
    endif
    "}}}4
endfunction
"{{{2 comp: автодополнение
"{{{3 comp.nrof
function s:F.comp.nrof(arglead)
    let s=split(a:arglead, '/')
    if len(s)<=1 && a:arglead[-1:][0]!=#'/'
        return map(keys(s:g.reg.registered), '"/".v:val."/"')
    else
        let path='/'.join(s, '/')
        let P=s:F.stuf.findpath(path)
        if type(P)==type({})
            return map(keys(P), 'path."/".v:val')
        elseif type(P)!=2
            unlet P
            let path='/'.join(s[:(-2)], '/')
            let P=s:F.stuf.findpath('/'.join(s[:(-2)], '/'))
            if type(P)==type({})
                return map(keys(P), 'path."/".v:val')
            endif
        endif
    endif
    return []
endfunction
"{{{3 comp._complete
function s:F.comp._complete(...)
    if !has_key(s:F.comp, "__complete")
        let s:F.comp.__complete=
                    \s:F.comm.run(s:F.plug.comp, "ccomp",
                    \             s:g.comp._cname, s:g.comp.a)
    endif
    return call(s:F.comp.__complete, a:000, {})
endfunction
"{{{3 s:g.comp
let s:g.comp={}
let s:g.comp.plug=["keyof", s:g.reg.registered]
let s:g.comp.event=["keyof", s:g.au.events]
let s:g.comp.a={"model": "actions"}
let s:g.comp.a.actions={}
let s:g.comp.a.actions.unload={"model": "simple",
            \              "arguments": [s:g.comp.plug]}
let s:g.comp.a.actions.reload={"model": "simple",
            \              "arguments": [s:g.comp.plug]}
let s:g.comp.a.actions.show={"model": "simple"}
let s:g.comp.a.actions.findnr={"model": "simple"}
let s:g.comp.a.actions.nrof={"model": "simple",
            \              "arguments": [["func", s:F.comp.nrof]]}
let s:g.comp.a.actions.autocmd={"model": "simple",
            \               "arguments": [s:g.comp.event, s:g.comp.plug]}
let s:g.comp.a.actions["autocmd!"]={"model": "simple",
            \                   "arguments": [s:g.comp.event, s:g.comp.plug]}
let s:g.comp.a.actions.mksession={"model": "simple",
            \                 "arguments": [["file", '.vim']]}
let s:g.comp._cname="load"
"{{{1
let s:g.reginfo=s:F.reg.register({
            \     "funcdict": s:F,
            \     "globdict": s:g,
            \      "fprefix": "Load",
            \      "cprefix": "Load",
            \      "oprefix": "load",
            \     "commands": s:g.load.commands,
            \    "functions": s:g.load.functions,
            \          "sid": s:g.scriptid,
            \   "scriptfile": s:g.load.scriptfile,
            \      "oneload": 1,
            \"dictfunctions": s:g.comm.f,
            \   "apiversion": "0.4",
        \})
lockvar! s:g.reginfo
let s:F.main.eerror=s:g.reginfo.functions.eerror
let s:F.main.option=s:g.reginfo.functions.option
unlet s:g.load
" let s:F.plug.comp=s:F.comm.getfunctions("comp")
let s:F.plug.comp=s:F.comm.lazyload("comp")
let s:F.plug.stuf=s:F.comm.lazyload("stuf")
let s:F.plug.yaml=s:F.comm.lazyload("yaml")
lockvar! s:F
unlockvar s:F.plug
unlockvar s:F.comp
lockvar s:g
" vim: ft=vim:ts=8:fdm=marker:fenc=utf-8

