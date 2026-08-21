let s:do_log = v:false

let s:log_label_list = [
    \ "ERROR",
    \ "WARN",
    \ "INFO",
    \ "TRACE",
    \ "DEBUG",
    \ "CONSOLE",
    \ "NOTICE",
    \ "WARNING",
    \ "ERR",
    \ "CRITICAL",
    \ "ALERT",
    \ "EMERGENCY",
\ ]

" Логи с длинной label + 4 строки
" Окно лучше оставлять маленьким
let s:window = 2

function s:log(msg, line = expand('<sflnum>'))
  if s:do_log
    call s:log_m(a:msg, a:line)
  endif
endfunction

function s:log_m(msg, line)
  let file = expand('<script>')
  echom printf("[%s:%s] %s", file, a:line, a:msg)
endfunction

" TODO пусть будет список b:fold_levels
" номер строки = позиция в списке
" кэш заполняется поэтапно в процессе вычисления файла
" Обнуление происходит при изменении b:changedtick
function s:log_fold()
  " if my_changedtick != b:changedtick
  "   let my_changedtick = b:changedtick
  "   call My_Update()
  " endif

  " func MyFoldFunc()
  "   if b:lasttick == b:changedtick
  "     return b:foldlevels[v:lnum - 1]
  "   endif
  "   let b:lasttick = b:changedtick
  "   let b:foldlevels = []
  "   " compute foldlevels ...
  "   return b:foldlevels[v:lnum - 1]
  " enddef
  " set foldexpr=s:MyFoldFunc()

  let current_line = v:lnum
  " cache
  let has_log_current = s:has_log_label(getline(current_line))
  " однострочный лог
  if has_log_current && s:has_log_label(getline(current_line + 1))
    call s:log(current_line .. " oneline log -> nowrap")
    return "0"
  endif
  " cache
  let has_log_down = s:has_log_down(current_line)
  " начало длинного лога
  " Защита от логов, с label + (s:window + 1) строк
  if has_log_current && !s:has_log_down(current_line, s:window + 2)
    call s:log(current_line .. " long log label -> wrap begin")
    return ">1"
  endif
  " вторая строка
  " Защита от логов, с label + (s:window + 1) строк
  if s:has_log_label(getline(current_line - 1))
    \ && s:has_log_down(current_line, s:window + 1)
    call s:log(current_line .. " line after small log label -> nowrap")
    return "0"
  endif
  " тело длинного лога
  if !has_log_current && !has_log_down
    call s:log(current_line .. " long log body -> wrap")
    return "1"
  endif
  " последняя строка
  " Защита от логов, с label + (s:window + 1) строк
  if s:has_log_label(getline(current_line + 1))
    \ && s:has_log_up(current_line, s:window + 1)
    call s:log(current_line .. " end of small log -> nowrap")
    return "0"
  endif
  " конец длинного лога
  if !has_log_current && has_log_down && !s:has_log_up(current_line)
    call s:log(current_line .. " end of long log -> wrap")
    return "1"
  endif
  return "0"
endfunction

function s:has_log_up(current_line, window = s:window)
  let begin = a:current_line - 1
  let end = begin - a:window + 1
  return reduce(
  \   range(begin, end, -1),
  \   {
  \     acc, line ->
  \     acc || s:has_log_label(getline(line))
  \   },
  \   v:false
  \ )
endfunction

function s:has_log_down(current_line, window = s:window)
  let begin = a:current_line + 1
  let end = begin + a:window - 1
  return reduce(
  \   range(begin, end, 1),
  \   {
  \     acc, line ->
  \     acc || s:has_log_label(getline(line))
  \   },
  \   v:false
  \ )
endfunction

" TODO сделать log_label_list как переменную по умолчанию
function s:has_log_label(line)
  " TODO можно соптимизировать: если поменяли на true, то остановить обход
  return reduce(
  \   s:log_label_list,
  \   {
  \     acc, log_label ->
  \     acc || match(a:line, "\\c" .. "\\<" .. log_label .. "\\>") != -1
  \   },
  \   v:false
  \ )
endfunction

" Подразумевается замена, т.к. у других filetype возможна своя реализация
function! FoldSyntax()
  setlocal foldexpr=s:log_fold()
  setlocal foldmethod=expr
endfunction

set colorcolumn=0
" :set filetype=log
" call FoldSyntax()

