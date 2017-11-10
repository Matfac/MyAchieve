let messageId = 1;
let logv = "",
    passv = "",
    tokv = "";
let userlogin = false;
let userinfo;
let gach = [],
    gexp = [],
    goedu = [],
    gid = -1;

function select(nelm, k) {
    k = k || 0;
    if (nelm[0] == "#") return document.getElementById(nelm.slice(1));
    else
    if (nelm[0] == ".") return document.getElementsByClassName(nelm.slice(1))[k];
    else
        return document.getElementsByTagName(nelm)[k];
}

function httpDo(url, type, opt, sfunc, efunc) {
    fetch(url, opt).then(function (response) {
        if (response.ok) {
            if (type == "json") return response.json();
            if (type == "text") return response.text();
        } else throw new Error("");
    }).then(function (out) {
        sfunc(out);
    }).catch(function (error) {
        efunc(error);
    });
}

function leaveW(nelm, clss) {
    let elm = select(nelm);
    if (clss == "show") {
        elm.className = elm.className.replace(clss, "");
        setTimeout("select('" + nelm + "').style.display = 'none';", 300);
    } else if (clss == "hide") {
        if (elm.className.indexOf(clss) == -1) elm.className += " " + clss;
        setTimeout("select('" + nelm + "').style.display = 'none';", 300);
    }
}

function showW(nelm, clss) {
    let elm = select(nelm);
    if (clss == "show") {
        elm.style.display = "inline-block";
        if (elm.className.indexOf(clss) == -1) setTimeout("select('" + nelm + "').className += ' ' + '" + clss + "';", 300);
    } else if (clss == "hide") {
        elm.style.display = "inline-block";
        setTimeout("select('" + nelm + "').className = select('" + nelm + "').className.replace('" + clss + "', '');", 300);
    }
}

function toggleW(nelm, clss) {
    let elm = select(nelm);
    if (clss == "show") {
        if (elm.className.indexOf(clss) == -1) {
            elm.style.display = "inline-block";
            setTimeout("select('" + nelm + "').className += ' ' + '" + clss + "';", 300);
        } else {
            elm.className = elm.className.replace(clss, "");
            setTimeout("select('" + nelm + "').style.display = 'none';", 300);
        }
    } else if (clss == "hide") {
        if (elm.className.indexOf(clss) > -1) {
            elm.style.display = "inline-block";
            setTimeout("select('" + nelm + "').className = select('" + nelm + "').className.replace('" + clss + "', '');", 300);
        } else {
            elm.className += " " + clss;
            setTimeout("select('" + nelm + "').style.display = 'none';", 300);
        }
    }
}

function addInfoBlock(elmin) {
    let infoblock = document.createElement('div');
    infoblock.className = "infoblock";
    elmin.appendChild(infoblock);
    return infoblock;
}

function addTitleBlock(title, elmin) {
    let infoblock = document.createElement('div');
    infoblock.className = "titleblock";
    infoblock.innerHTML = title;
    elmin.appendChild(infoblock);
    return infoblock;
}

function addContCat(cat, val, elmin) {
    let cont = "<div class='cont'>" +
        "   <div class='cat'>" + cat + "</div>" +
        "   <div class='val'>&nbsp;" + val + "</div>" +
        "</div>";
    elmin.innerHTML += cont;
}

function addContTitle(title, title2, elmin) {
    let cont = "<div class='cont'>";
    if (title) cont += "   <div class='title'>" + title + "</div>";
    if (title2) cont += "   <div class='title2'>" + title2 + "</div>";
    cont += "</div>";
    elmin.innerHTML += cont;
}

function addContA(atext, oncl, elmin) {
    let cont = "<div class='cont'><a href='' onclick='" + oncl + "; return false;'>" + atext + "</a></div>";
    elmin.innerHTML += cont;
}

function uploadImg(fname, fload) {
    let inp = document.getElementsByClassName(fname)[0].files[0];
    let inptype = inp.type.split("/");
    if (inp.size <= 512000 && inptype[0] == "image" && (inptype[1] == "jpeg" || inptype[1] == "png")) {
        let headers = new Headers();
        headers.append('Authorization', 'Basic ' + tokv);
        let formData = new FormData(document.getElementById(fname));
        httpDo("../auth/saveimg", "text", {
            method: "POST",
            headers: headers,
            body: formData
        }, function (data) {
            select("#" + fload).value = data;
            showMessage("Изображение успешно загружено", "success");
        }, function (data) {
            showMessage("Не соответствует формату (jpeg, png) или размер изображения > 500 килобайт.", "error");
        });
    } else showMessage("Не соответствует формату (jpeg, png) или размер изображения > 500 килобайт.", "error");
}

function clearStudent() {
    gach = [];
    gexp = [];
    goedu = [];
    gid = -1;
    select("#StLogin").value = "None";
    select("#Surname").value = "";
    select("#Name").value = "";
    select("#Patronymic").value = "";
    select("#Birthday").value = "";
    select("#Foa").value = 1;
    select("#SCity").value = "";
    select("#SStreet").value = "";
    select("#SHome").value = "";
    select("#SZipCode").value = "";
    select("#userbl3").style.display = "none";
    select("#infostud").style.display = "block";
    addAchAll("#infostud");
}

function editStudent(i) {
    select("#StLogin").value = userinfo.User.Events[i].Login;
    select("#Surname").value = userinfo.User.Events[i].Surname;
    select("#Name").value = userinfo.User.Events[i].Name;
    select("#Patronymic").value = userinfo.User.Events[i].Patronymic;
    select("#Birthday").value = userinfo.User.Events[i].Birthday;
    select("#Foa").value = userinfo.User.Events[i].Foa;
    select("#SCity").value = userinfo.User.Events[i].Address.City;
    select("#SStreet").value = userinfo.User.Events[i].Address.Street;
    select("#SHome").value = userinfo.User.Events[i].Address.Home;
    select("#SZipCode").value = userinfo.User.Events[i].Address.ZipCode;
    gach = userinfo.User.Events[i].Achievements;
    gexp = userinfo.User.Events[i].Experience;
    goedu = userinfo.User.Events[i].OtherEduc;
    select("#userbl3").style.display = "none";
    select("#infostud").style.display = "block";
    addAchAll("#infostud");
}

function showStudent(i) {
    let ss = select("#studshow");
    ss.innerHTML = "";
    let foa = ["Спорт", "Образование, наука", "Управление и общественная деятельность", "Культура и искусство", "Техники", "Предпринимательство"];
    let infbl = addInfoBlock(ss);
    addTitleBlock("Информация об "+userinfo.User.Events[i].Surname+" "+userinfo.User.Events[i].Name+" "+userinfo.User.Events[i].Patronymic, infbl);
    addContCat("День рождения:", userinfo.User.Events[i].Birthday, infbl);
    addContCat("Сфера деятельности:", foa[userinfo.User.Events[i].Foa - 1], infbl);
    addContCat("Город:", userinfo.User.Events[i].Address.City, infbl);
    gach = userinfo.User.Events[i].Achievements;
    gexp = userinfo.User.Events[i].Experience;
    goedu = userinfo.User.Events[i].OtherEduc;
    ss.innerHTML += "<div id='studshowach'></div>";
    addAchAll("#studshowach");
}

function addStudents() {
    let bl3 = select("#userbl3");
    bl3.innerHTML = "";
    let foa = ["Спорт", "Образование, наука", "Управление и общественная деятельность", "Культура и искусство", "Техники", "Предпринимательство"];
    let infbl, titbl;
    for (let i = 0; i < userinfo.User.Events.length; i++) {
        infbl = addInfoBlock(bl3);
        addTitleBlock(userinfo.User.Events[i].Surname + " " + userinfo.User.Events[i].Name + " " + userinfo.User.Events[i].Patronymic, infbl);
        if (userinfo.Type == "Организатор") addContCat("Логин:", userinfo.User.Events[i].Login, infbl);
        addContCat("День рождения:", userinfo.User.Events[i].Birthday, infbl);
        addContCat("Сфера деятельности:", foa[userinfo.User.Events[i].Foa - 1], infbl);
        if (userinfo.Type == "Организатор") addContA("Редактировать обучающего", "editStudent(" + i + ")", infbl);
        if (userinfo.Type == "Работодатель") addContA("Показать достижения", "showStudent(" + i + ")", infbl);
    }
}

function leaveAch() {
    select("#infostud").style.display = "none";
    select("#userbl3").style.display = "block";
}

function addAchAll(blname) {
    let ist = select(blname);
    ist.innerHTML = "";
    let ex = false;
    let infbl;
    if (gach.length > 0) {
        ex = true;
        let level = ["Образовательная организация", "Муниципальный", "Региональный", "Всероссийский", "Международный"];
        let eresult = ["Участник", "Победитель", "Призёр", "Организатор", "Лауреат"];
        let a, durl;
        for (let i = 0; i < gach.length; i++) {
            infbl = addInfoBlock(ist);
            if (i == 0) {
                addTitleBlock("Достижения", infbl);
                if (userinfo.Type == "Организатор") addContA("Вернуться обратно", "leaveAch()", infbl);
            }
            a = gach[i];
            addContCat("Название:", a.Title, infbl);
            addContCat("Уровень:", level[a.Level - 1], infbl);
            addContCat("Место:", a.City, infbl);
            addContCat("Год проведения:", a.Year, infbl);
            addContCat("Результат:", eresult[a.EventResult - 1], infbl);
            if (a.VerifyPhoto) durl = "<a href='http://194.177.21.52:57772/img/" + a.VerifyPhoto + "'>перейти по ссылке</a>";
            else durl = "";
            addContCat("Фото:", durl, infbl);
            if (a.VerifyVideo) durl = "<a href='" + a.VerifyVideo + "'>перейти по ссылке</a>";
            else durl = "";
            addContCat("Видео:", durl, infbl);
            if (a.VerifyImg) durl = "<a href='http://194.177.21.52:57772/img/" + a.VerifyImg + "'>перейти по ссылке</a>";
            else durl = "";
            addContCat("Документ:", durl, infbl);
        }
    }
    if (gexp.length > 0) { ex = true; addExpAll(blname); }
    if (goedu.length > 0) { ex = true; addOEduAll(blname); }
    if (ex == false) {
        infbl = addInfoBlock(ist);
        addTitleBlock("Достижения", infbl);
        if (userinfo.Type == "Организатор") addContA("Пока нет. Вернуться обратно", "leaveAch()", infbl);
        if (userinfo.Type == "Работодатель") addContA("Пока ничего нет.", "", infbl);
    }
}

function addExpAll(blname) {
    let ist = select(blname);
    let getexp = ["стажировка", "практика", "профессиональная проба", "другое"];
    let a, durl;
    for (let i = 0; i < gexp.length; i++) {
        infbl = addInfoBlock(ist);
        if (i == 0) addTitleBlock("Опыт практической деятельности", infbl);
        a = gexp[i];
        addContCat("Форма получения опыта:", getexp[a.GetExp - 1], infbl);
        addContCat("Название:", a.Name, infbl);
        addContCat("Организатор:", a.Organizer, infbl);
        addContCat("Страна:", a.Country, infbl);
        addContCat("Город:", a.City, infbl);
        if (a.VerifyPhoto) durl = "<a href='http://194.177.21.52:57772/img/" + a.VerifyPhoto + "'>перейти по ссылке</a>";
        else durl = "";
        addContCat("Фото:", durl, infbl);
        if (a.VerifyVideo) durl = "<a href='" + a.VerifyVideo + "'>перейти по ссылке</a>";
        else durl = "";
        addContCat("Видео:", durl, infbl);
        if (a.VerifyImg) durl = "<a href='http://194.177.21.52:57772/img/" + a.VerifyImg + "'>перейти по ссылке</a>";
        else durl = "";
        addContCat("Документ:", durl, infbl);
        if (a.VerifyUrl) durl = "<a href='" + a.VerifyUrl + "'>перейти по ссылке</a>";
        else durl = "";
        addContCat("Сайт:", durl, infbl);
    }
}

function addOEduAll(blname) {
    let ist = select(blname);
    let tdoc = ["Сертификат", "Удостоверение", "Диплом", "Свидетельство", "Другое"];
    let a;
    for (let i = 0; i < goedu.length; i++) {
        infbl = addInfoBlock(ist);
        if (i == 0) addTitleBlock("Дополнительное образование", infbl);
        a = goedu[i];
        addContCat("Организация:", a.Organizer, infbl);
        addContCat("Город:", a.City, infbl);
        addContCat("Компетенция/квалификация:", a.Qualification, infbl);
        addContCat("Вид документа:", tdoc[a.TypeDoc - 1], infbl);
        addContCat("Количество часов:", a.Hours, infbl);
        addContCat("Дата получения документа:", a.DateDoc, infbl);
    }
}

function addAch() {
    let f = getForm("achieve");
    gach.push(f);
    showMessage("Добавлено!", "success");
    addAchAll("#infostud");
}

function addExp() {
    let f = getForm("experience");
    f.Exp = select("#Exp-Exp").value();
    gexp.push(f);
    showMessage("Добавлено!", "success");
    addAchAll("#infostud");
}

function addOEdu() {
    let f = getForm("othereduc");
    goedu.push(f);
    showMessage("Добавлено!", "success");
    addAchAll("#infostud");
}

function showMessage(mtext, clss) {
    let elm = select(".message");
    let mssg = elm.cloneNode(true);
    mssg.id = "message" + messageId;
    mssg.className += " " + clss;
    mssg.style.top = 23 + (messageId - 1) * 31 + "px";
    let tmssg = mssg.querySelector("b");
    tmssg.innerHTML = mtext;
    setTimeout("select('#message" + messageId + "').className += ' hide';", 3000);
    setTimeout("document.body.removeChild(select('#message" + messageId + "')); if (" + (messageId + 1) +
        " == messageId) messageId = 1;", 3500);
    document.body.appendChild(mssg);
    setTimeout("select('#message" + messageId + "').className += ' show';", 10);
    messageId++;
}

function getCook(name) {
    if (document.cookie) {
        var cooks = document.cookie.split("; ");
        for (let i = 0; i < cooks.length; i++) {
            let cook = cooks[i].split("=");
            if (cook[0] == name) return cook[1];
        }
    }
    return false;
}

function delCook(name) {
    var cookie_date = new Date();
    cookie_date.setTime(cookie_date.getTime() - 1);
    document.cookie = name + "=; expires=" + cookie_date.toGMTString();
}

function searchStudents() {
    let f = getForm("searchst");
    let format = f.SearchFoa+"-"+f.SearchMinAge+"-"+f.SearchMaxAge;
    let headers = new Headers();
    headers.append('Authorization', 'Basic ' + tokv);
    httpDo("../auth/getst/"+format, "json", {
        method: "POST",
        headers: headers
    }, function (data) {
        userinfo.User.Events = data.Events;
        addStudents();
    }, function (data) {
        showMessage("Ошибка при поиске.", "error");
    });
}

function doUserAction(action, data) {
    if (action == "login") {
        userlogin = true;
        userinfo = data;
        //alert(JSON.stringify(data));
        //userinfo.User.DelEvents = [];
        // alert(JSON.stringify(userinfo));

        if (userinfo.Type == "Обучающийся") {
            //let birthday = userinfo.User.Birthday.split("-");
            userinfo.User.ShowBirthday = userinfo.User.Birthday;

            let userbl1 = select("#bl1");
            userbl1.innerHTML = "";
            addTitleBlock(userinfo.User.Surname + " " + userinfo.User.Name + " " + userinfo.User.Patronymic, userbl1);
            addContCat("Тип аккаунта:", "Обучающийся", userbl1);
            addContCat("День рождения:", userinfo.User.ShowBirthday, userbl1);
            addContCat("Город:", userinfo.User.Address.City, userbl1);
            addContCat("Улица:", userinfo.User.Address.Street, userbl1);
            addContCat("Дом:", userinfo.User.Address.Home, userbl1);
            addContCat("Индекс:", userinfo.User.Address.ZipCode, userbl1);

            gach = userinfo.User.Achievements;
            gexp = userinfo.User.Experience;
            goedu = userinfo.User.OtherEduc;

            select("#userbl3").style.display = "none";
            select("#infostud").style.display = "block";
            addAchAll("#infostud");
        }
        if (userinfo.Type == "Организатор") {
            //if (select("#evmenu").class().indexOf("hidefull") > -1) {
            //    select("#evmenu").removeClass("hidefull");
            //}
            for (let i = 0; i < userinfo.User.Events.length; i++) {
                for (let j = 0; j < userinfo.User.Events[i].OtherEduc.length; j++) {
                    let d = userinfo.User.Events[i].OtherEduc[j].DateDoc.split("-");
                    userinfo.User.Events[i].OtherEduc[j].DateDoc = d[2] + "." + d[1] + "." + d[0];
                }
            }

            let userbl1 = select("#bl1");
            userbl1.innerHTML = "";
            addTitleBlock(userinfo.User.Title, userbl1);
            addContCat("Тип аккаунта:", "Учреждение", userbl1);
            addContCat("Электронная почта:", userinfo.User.Email, userbl1);
            addContCat("Телефоны:", userinfo.User.Phones, userbl1);
            addContCat("Город:", userinfo.User.Address.City, userbl1);
            addContCat("Улица:", userinfo.User.Address.Street, userbl1);
            addContCat("Дом:", userinfo.User.Address.Home, userbl1);
            addContCat("Индекс:", userinfo.User.Address.ZipCode, userbl1);
            
            select("#userbl3").style.display = "block";
            showW("#studeditor", "hide");
            addStudents();
        }
        if (userinfo.Type == "Работодатель") {
            //select(".username").html("Вы вошли как: " + userinfo.User.Title + " (" + userinfo.Type + ")");
            let userbl1 = select("#bl1");
            userbl1.innerHTML = "";
            addTitleBlock(userinfo.User.Title, userbl1);
            addContCat("Тип аккаунта:", "Работодатель", userbl1);
            addContCat("ФИО Руководителя:", userinfo.User.Chief, userbl1);
            addContCat("Электронная почта:", userinfo.User.Email, userbl1);
            addContCat("Телефоны:", userinfo.User.Phones, userbl1);
            addContCat("Город:", userinfo.User.Address.City, userbl1);
            addContCat("Улица:", userinfo.User.Address.Street, userbl1);
            addContCat("Дом:", userinfo.User.Address.Home, userbl1);
            addContCat("Индекс:", userinfo.User.Address.ZipCode, userbl1);

            select("#studshow").style.display = "block";
            select("#searchst").style.display = "block";
            select("#userbl3").style.display = "block";
        }
        leaveW("#logreg", "hide");
        leaveW("#logenter", "hide");
        showW("#logexit", "hide");
        showW("#bl1", "show");
        showW("#bl2", "show");
        showW("#bl3", "show");
    }
    if (action == "exit") {
        userlogin = false;
        leaveW("#bl1", "show");
        leaveW("#bl2", "show");
        leaveW("#bl3", "show");
        leaveW("#studeditor", "hide");
        leaveW("#studshow", "hide");
        select("#searchst").style.display = "none";
        select("#infostud").innerHTML = "";
        select("#studshow").innerHTML = "";
        select("#userbl3").innerHTML = "";
        setTimeout(function () {
            showW("#logenter", "hide");
            showW("#logreg", "hide");
        }, 350);
        leaveW("#logexit", "hide");
        /*if (select("#evmenu").class().indexOf("hidefull") == -1) {
            select("#evmenu").addClass("hidefull");
        }*/
        //select("#filestream").attribute("hidden","");
        //eventselect = 0;
        //redrawv = false;
    }
}

function getForm(formid) {
    let inform = select("#" + formid);
    let childs = inform.querySelectorAll("*");
    var out = {};
    for (let i = 0; i < childs.length; i++) {
        if (childs.item(i).name) {
            if ("City Street Home ZipCode".indexOf(childs.item(i).name) > -1) {
                if (!out.Address) out.Address = {};
                out.Address[childs.item(i).name] = childs.item(i).value;
            } else
            if (childs.item(i).name.indexOf("-") > -1) {
                out[childs.item(i).name.split("-")[1]] = childs.item(i).value;
            } else {
                if (childs.item(i).name == "Phones" || childs.item(i).name == "CoordPhones")
                    out[childs.item(i).name] = childs.item(i).value.split(",");
                else
                if (childs.item(i).name == "Birthday") {
                    if (childs.item(i).value.indexOf("-") == 4)
                        out[childs.item(i).name] = childs.item(i).value;
                    else {
                        let birthday = childs.item(i).value.split(".");
                        out[childs.item(i).name] = birthday[2] + "-" + birthday[1] + "-" + birthday[0];
                    }
                } else
                    out[childs.item(i).name] = childs.item(i).value;
            }
        }
    }
    out.Type = formid;
    return out;
}

function toggleTopbar() {
    if ((getCook("logv")) && (getCook("tokv"))) {
        logv = getCook("logv");
        tokv = getCook("tokv");
        let headers = new Headers();
        headers.append('Authorization', 'Basic ' + tokv);
        httpDo("../auth/", "json", {
            method: 'POST',
            headers: headers,
        }, function (data) {
            doUserAction("login", data);
        });
    }
}

function exitClick() {
    if ((getCook("logv")) && (getCook("tokv"))) {
        delCook("logv");
        delCook("tokv");
        logv = "";
        passv = "";
        tokv = "";
        doUserAction("exit");
    }
}

function regClick(formid) {
    if ((logv) && (tokv) && (userinfo.Type == "Организатор") && (formid == "student")) {
        let jsonobj = getForm(formid);
        jsonobj.Achievements = gach;
        jsonobj.Experience = gexp;
        jsonobj.OtherEduc = goedu;
        let headers = new Headers();
        headers.append('Authorization', 'Basic ' + tokv);
        httpDo("../auth/reg", "text", {
            method: 'POST',
            headers: headers,
            body: JSON.stringify(jsonobj)
        }, function (data) {
            //userinfo = {};
            //userinfo = data;
            //gach = userinfo.User.Events[gid].Achievements;
            //gexp = userinfo.User.Events[gid].Experience;
            //goedu = userinfo.User.Events[gid].OtherEduc;
            /*for (let i = 0; i < userinfo.User.Events.length; i++) {
                for (let j = 0; j < userinfo.User.Events[i].OtherEduc.length; j++) {
                    let d = userinfo.User.Events[i].OtherEduc[j].DateDoc.split("-");
                    userinfo.User.Events[i].OtherEduc[j].DateDoc = d[2] + "." + d[1] + "." + d[0];
                }
            }*/
            showMessage("Успешное сохранение!", "success");
        }, function (data) {
            showMessage("Произошла ошибка во время сохранения.", "error");
        });
    }
    if ((!logv) && (!tokv)) {
        let jsonobj = getForm(formid);
        httpDo("../reg", "text", {
            method: "POST",
            body: JSON.stringify(jsonobj)
        }, function (data) {
            showMessage("Вы успешно зарегистрировались!", "success");
            leaveW("#regbar", "show");
        }, function (data) {
            showMessage("Произошла ошибка во время регистрации.", "error");
        });
    }
}

function logClick() {
    logv = select("#menu_login").value;
    passv = select("#menu_password").value;
    if ((logv) && ((passv) || (tokv))) {
        let headers = new Headers();
        if (!tokv) tokv = btoa("sa_" + logv + ":" + passv);
        headers.append("Authorization", "Basic " + tokv);
        httpDo("../auth/", "json", {
            method: "POST",
            headers: headers,
        }, function (data) {
            if ((!getCook("logv")) && (!getCook("tokv"))) {
                showMessage("Успех!", "success");
                leaveW("#regbar", "show");
                document.cookie = "logv=" + logv;
                document.cookie = "tokv=" + tokv;
                passv = "";
                doUserAction("login", data);
                toggleW("#loginbar", "show");
            }
        }, function (data) {
            tokv = "";
            showMessage("Ошибка входа! Неверное имя пользователя или пароль.", "error");
        });
    }
}

window.onload = function () {
    select("#bl2").style.height = (window.innerHeight-55)+"px";
    select("#bl3").style.height = (window.innerHeight-55)+"px";
    toggleTopbar();
};

document.body.onresize = function () {
    select("#bl2").style.height = (window.innerHeight-55)+"px";
    select("#bl3").style.height = (window.innerHeight-55)+"px";
};