"{{{1 Первая загрузка
scriptencoding utf-8
if !exists('s:_pluginloaded')
    execute frawor#Setup('1.0', {'@/functions': '0.0',
                \                       '@oop': '1.0',
                \                '@/resources': '0.0',
                \                      '@/fwc': '0.0',}, 0)
    call map(['oop', 'bi'], 'extend(s:F, {v:val : {}})')
    finish
elseif s:_pluginloaded
    finish
endif
"{{{1 _messages
if v:lang=~?'ru'
    let s:_messages={
                \    'cldef': 'Класс «%s» уже определён дополнением %s',
                \    'clcol': 'В зависимостях определены два класса '.
                \             'с одинаковым именем',
                \'uncexcept': 'Непойманное исключение: %s',
            \}
else
    let s:_messages={
                \    'cldef': 'Class `%s'' was already defined by plugin %s',
                \    'clcol': 'There is more then one class with equal name '.
                \             'defined in dependencies',
                \'uncexcept': 'Uncaught exception: %s',
            \}
endif
"{{{1 Вторая загрузка — функции
"{{{2 pyoop feature
let s:F.pyoop={}
let s:classes={}
"{{{3 pyoop.register
function s:F.pyoop.register(plugdict, fdict)
    if !has_key(a:plugdict.g, '_classes') ||
                \type(a:plugdict.g._classes)!=type({})
        let a:plugdict.g._classes={}
    endif
endfunction
"{{{3 pyoop.load
function s:F.pyoop.load(plugdict, fdict)
    for dep in keys(a:plugdict.dependencies)
        if dep isnot# a:plugdict.id && has_key(s:classes, dep)
            try
                call extend(a:plugdict.g._classes, s:classes[dep], 'error')
            catch /^Vim(call):E737:/
                call s:_f.throw('clcol')
            endtry
        endif
    endfor
endfunction
"{{{3 pyoop.cons
let s:F.pyoop.cons={}
function s:F.pyoop.cons.class(plugdict, fdict, name, functions, vars, parents)
    "{{{4 Проверка аргументов
    if has_key(a:plugdict.g._classes, a:name) &&
                \type(a:plugdict.g._classes[a:name])==type({}) &&
                \has_key(a:plugdict.g._classes[a:name], 'plid') &&
                \s:classes[a:plugdict.g._classes[a:name].plid][a:name] is#
                \                                  a:plugdict.g._classes[a:name]
        call s:_f.throw('cldef', a:name, a:plugdict.g._classes[a:name].plid)
    endif
    if !has_key(s:classes, a:plugdict.id)
        let s:classes[a:plugdict.id]=a:fdict
    elseif has_key(s:classes[a:plugdict.id], a:name)
        call s:_f.throw('cldef', a:name, a:plugdict.id)
    endif
    "}}}4
    let class={'plid': a:plugdict.id, 'name': a:name, 'F': {}}
    let class.vars=a:vars
    let class.parents=map(copy(a:parents), 'a:plugdict.g._classes[v:val]')
    call s:F.oop.setfunctions(class, filter(copy(a:functions),
                \                           'type(v:val)==2'),
                \             class.parents)
    let class.new=s:F.oop.new
    lockvar! class.parents
    lockvar 1 class
    let a:fdict[a:name]=class
    let a:plugdict.g._classes[a:name]=class
    return class
endfunction
let s:F.pyoop.cons.class=s:_f.wrapfunc({'function': s:F.pyoop.cons.class,
            \'@FWC': ['_ _ match /\v^\w+$/ '.
            \             'dict {-  isfunc 1} '.
            \             '[:={} type {} '.
            \             '[:=[] list key @<<<<<.g._classes]]', 'filter']})
"{{{3 pyoop.unload
function s:F.pyoop.unload(plugdict, fdict)
    if has_key(s:classes, a:plugdict.id)
        unlet s:classes[a:plugdict.id]
    endif
endfunction
"{{{3 Register feature
let s:F.pyoop.ignoredeps=1
call s:_f.newfeature('pyoop', s:F.pyoop)
"{{{2 oop: class, instance
"{{{3 oop.setfunctions
function s:F.oop.setfunctions(class, functions, parents)
    if !empty(a:functions)
        call extend(a:class.F, a:functions, 'keep')
    endif
    for parent in a:parents
        call s:F.oop.setfunctions(a:class, parent.F, parent.parents)
    endfor
endfunction
"{{{3 oop.getc
function s:F.oop.getc(class, first)
    let r={}
    if !empty(a:class.vars)
        call extend(r, deepcopy(a:class.vars))
    endif
    if a:first
        call extend(r, a:class.F)
    endif
    return r
endfunction
"{{{3 oop.setinstance
function s:F.oop.setinstance(class, instance, first, args)
    if !empty(a:class.parents)
        if len(a:class.parents)==1
            let super=s:F.oop.getc(a:class.parents[0], 1)
        else
            let super={}
            for parent in a:class.parents
                let super[parent.name]=s:F.oop.getc(parent, 1)
            endfor
        endif
        for parent in a:class.parents
            call s:F.oop.setinstance(parent, a:instance, 0, a:args)
        endfor
    else
        let super=0
    endif
    call extend(a:instance, s:F.oop.getc(a:class, a:first))
    let hasconstructor=has_key(a:class.F, '__init__')
    if a:first && hasconstructor
        call call(a:class.F.__init__, [super]+a:args, a:instance)
    endif
endfunction
"{{{3 oop.new
function s:F.oop.new(...)
    let instance={'__class__':     self,
                \ '__variables__': self.vars,}
    call s:F.oop.setinstance(self, instance, 1, a:000)
    return instance
endfunction
"{{{2 pyoop resource
let s:pyoop={}
"{{{3 pyoop.instanceof
function s:pyoop.instanceof(name, instance)
    if a:instance.__class__.name is# a:name
        return 1
    else
        let parents=copy(a:instance.__class__.parents)
        while !empty(parents)
            let parent=remove(parents, 0)
            if parent.name is# a:name
                return 1
            endif
            let parents+=parent.parents
        endwhile
    endif
    return 0
endfunction
"{{{3 Register resource
call s:_f.postresource('pyoop', s:pyoop)
"{{{2 bi
"{{{3 bi.Exception
let s:F.bi.Exception={}
"{{{4 bi.Exception.raise
function s:F.bi.Exception.raise()
    throw self.warn()
endfunction
"{{{4 bi.Exception.warn
function s:F.bi.Exception.warn()
    let str=self.__str__()
    echohl ErrorMsg
    echo str
    echohl None
    return str
endfunction
"{{{4 bi.__str__
function s:F.bi.Exception.__str__()
    return printf(s:_messages.uncexcept, self.__class__.name)
endfunction
"{{{4 Создание класса
call s:_f.pyoop.class('Exception', s:F.bi.Exception)
"{{{1
call frawor#Lockvar(s:, 'classes,_pluginloaded')
" vim: ft=vim:ts=8:fdm=marker:fenc=utf-8
