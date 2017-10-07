class Component {
    constructor(selector) {
        this.selector = selector;
        this.html = "";
        this.css = "";
        this.slr = "";
    }
    init(sf, uniq) {
        this.slr = select("." + this.selector);
        var comp = this;
        httpGet("src/" + this.selector + "/" + this.selector + ".html", "text", false, function (data) {
            comp.html = data;
            if (uniq) {
                for (let i = 0; i < uniq.length; i++)
                    data = data.replace("{" + i + "}", uniq[i]);
            }
            comp.slr.html(data);
            if (sf) sf();
        });
        httpGet("src/" + this.selector + "/" + this.selector + ".css", "text", false, function (data) {
            comp.css = data;
            let style = select("style");
            let cssarr = split(comp.css, "}");
            let newarr = [];
            for (let i = 0; i < cssarr.length - 1; i++) {
                if (cssarr[i].indexOf(":host") < 0)
                    newarr.push("." + comp.selector + " " + cssarr[i]);
                else newarr.push("." + comp.selector + " " + cssarr[i].replace(":host", ""));
            }
            newarr.push("");
            style.html(join(newarr, "}"), true);
            comp.slr.removeAttribute('hidden');
        });
    }
    copy(uniq) {
        let ghtml = this.html;
        if (uniq) {
            for (let i = 0; i < uniq.length; i++)
                ghtml = ghtml.replace("{" + i + "}", uniq[i]);
        }
        this.slr.html(this.slr.html() + ghtml);
        return this.slr.child().item(this.slr.child().length - 1);
    }
    clear() {
        this.slr.html("");
    }
}

let sa_transx = 0,
    sa_transy = 0,
    sa_ptransx = 0,
    sa_ptransy = 0,
    sa_gclick = 0,
    sa_scrolly = 0,
    sa_scrollymax = 1;

function sa_clearTranslate() {
    sa_transx = 0;
    sa_transy = sa_scrolly;
    sa_ptransx = 0;
    sa_ptransy = 0;
    translate(0, sa_scrolly);
}

function sa_translate(x, y) {
    translate(x, y);
    sa_transx += x;
    sa_transy += y;
}

function sa_push() {
    sa_ptransx = sa_transx;
    sa_ptransy = sa_transy;
    push();
}

function sa_pop() {
    pop();
    sa_transx = sa_ptransx;
    sa_transy = sa_ptransy;
}

function sa_inrect(x, y, w, h) {
    let res = false;
    if ((mouseX >= x) && (mouseX <= x + w) &&
        (mouseY >= y) && (mouseY <= y + h)) res = true;
    return res;
}

function sa_btn(x, y, w, h, bclick, bhover) {
    if (sa_inrect(sa_transx + x, sa_transy + y, w, h)) {
        if (bclick && sa_gclick == 1) {
            sa_gclick = -1;
            bclick();
        } else if (bhover) {
            bhover();
        }
    }
}

function sa_rect(x, y, w, h, bclick, bhover) {
    bclick = bclick || "";
    bhover = bhover || "";
    sa_btn(x, y, w, h, bclick, bhover);
    rect(x, y, w, h);
}

function sa_text(dtext, x, y, bclick, bhover) {
    bclick = bclick || "";
    bhover = bhover || "";
    let ts = textSize();
    let tw = textWidth(dtext);
    sa_btn(x, y - ts, tw, ts, bclick, bhover);
    text(dtext, x, y);
}

function leaveWindow(idw, t, ch, chf) {
    t = t || 300;
    ch = ch || "hide";
    chf = chf || "hidefull";
    select(idw).addClass(ch);
    setTimeout("select('" + idw + "').addClass('" + chf + "')", t);
}

function showWindow(idw, t, ch, chf) {
    t = t || 300;
    ch = ch || "hide";
    chf = chf || "hidefull";
    select(idw).removeClass(chf);
    setTimeout("select('" + idw + "').removeClass('" + ch + "')", t);
}

function showMessage(mtext, clss) {
    cmessage.copy([clss, 18 + messageId * 31 + "px", messageId, mtext]);
    select("#messagetext" + messageId).parent().className += " show";
    setTimeout("select('#messagetext" + messageId + "').parent().className += ' hide';", 3000);
    setTimeout("select('#messagetext" + messageId + "').parent().remove(); if (" + (messageId + 1) +
        " == messageId) messageId = 0;", 3500);
    messageId++;
}

function toggleClass(elm, clss) {
    let className = elm.className;
    if (className.indexOf(clss) == -1) {
        className += " " + clss;
    } else {
        className = className.replace(clss, "");
    }
    elm.className = className;
}

function doUserAction(action, data) {
    if (action == "login") {
        userlogin = true;
        gslide = 0;
        gclick = 0;
        gshst = -1;
        userinfo = {};
        userinfo = JSON.parse(data);
        userinfo.User.DelEvents = [];

        if (userinfo.Type == "Обучающийся") {
            select(".username").html("Вы вошли как: " + userinfo.User.Surname + "  " +
                userinfo.User.Name + " (" + userinfo.Type + ")");
            let birthday = userinfo.User.Birthday.split("-");
            userinfo.User.ShowBirthday = birthday[2] + "." + birthday[1] + "." + birthday[0];
            sa_scrollymax = 190 * userinfo.User.Events.length;
        }
        if (userinfo.Type == "Организатор") {
            select(".username").html("Вы вошли как: " + userinfo.User.Title + " (" + userinfo.Type + ")");
            if (select("#evmenu").class().indexOf("hidefull") > -1) {
                select("#evmenu").removeClass("hidefull");
            }
            sa_scrollymax = 190 * userinfo.User.Events.length;
        }
        if (userinfo.Type == "Работодатель") {
            select(".username").html("Вы вошли как: " + userinfo.User.Title + " (" + userinfo.Type + ")");
        }
        showWindow("#logexit");
        leaveWindow("#logenter");
        leaveWindow("#logreg");
        if (userinfo.User.Logo) logoimg = loadImage("../img/" + userinfo.User.Logo, function () {
            logoimg.resize(0, width * 0.16 * 1.2 - 20);
        });
        else logoimg = loadImage("img/logo.jpg", function () {
            logoimg.resize(0, width * 0.16 * 1.2 - 20);
        });
        select("#filestream").removeAttribute('hidden');
        redrawv = true;
    }
    if (action == "exit") {
        leaveWindow("#logexit");
        showWindow("#logenter");
        showWindow("#logreg");
        if (select("#evmenu").class().indexOf("hidefull") == -1) {
            select("#evmenu").addClass("hidefull");
        }
        select("#filestream").attribute("hidden","");
        eventselect = 0;
        redrawv = false;
    }
}

function toggleTopbar() {
    if ((getCook("logv")) && (getCook("tokv"))) {
        logv = getCook("logv");
        tokv = getCook("tokv");
        let headers = new Headers();
        headers.append('Authorization', 'Basic ' + tokv);
        httpDo("../auth/", {
            method: 'POST',
            headers: headers,
        }, function (data) {
            doUserAction("login", data);
        });
    }
}

function saveUser() {
    if ((getCook("logv")) && (getCook("tokv"))) {
        logv = getCook("logv");
        tokv = getCook("tokv");
        let headers = new Headers();
        headers.append('Authorization', 'Basic ' + tokv);
        httpDo("../auth/save", {
            method: 'POST',
            headers: headers,
            body: JSON.stringify(userinfo.User)
        }, function (data) {
            userinfo = JSON.parse(data);
            if (userinfo.Type == "Обучающийся") {
                let birthday = userinfo.User.Birthday.split("-");
                userinfo.User.ShowBirthday = birthday[2] + "." + birthday[1] + "." + birthday[0];
            }
            userinfo.User.DelEvents = [];
            //events.Events = userinfo.User.Events;
            //maxEvent = Math.round(events.Events.length / 10 + 0.5);
            //refreshEvents();
            showMessage("Сохранение завершено.", "success");
        }, function (data) {
            showMessage("Произошла ошибка во время сохранения!", "error");
        });
    }
}

//-------- front-end -------------//
function showLoginMenu() {
    let lm = loginmenu.slr.child().item(0);
    toggleClass(lm, "show");
}

function showRegMenu() {
    //let rm = regmenu.slr.child().item(0);
    //toggleClass(rm, "showpanel");
    if (select("#regmenu").class().indexOf("hide") > -1) showWindow("#regmenu");
    else leaveWindow("#regmenu");
}

function regChoose(type) {
    let sp = ["student", "organizer", "employer"];
    for (let i = 0; i < sp.length; i++) {
        if (type != sp[i]) {
            if ((select("#" + sp[i]).class().indexOf("hide") == -1) ||
                (select("#" + sp[i]).class().indexOf("hidefull") == -1)) {
                select("#" + sp[i]).addClass("hidefull");
                select("#" + sp[i]).addClass("hide");
            }
            select("#choose" + sp[i]).removeClass("choose-select");
        }
    }

    let ch = select("#" + type);
    if (ch.class().indexOf("hide") > -1)
        showWindow("#" + type);
    //setTimeout("showWindow('#"+type+"')", 300);
    ch = select("#choose" + type);
    if (ch.class().indexOf("choose-select") == -1)
        ch.addClass("choose-select");
}
//---------- work with back-end -------------//
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

var logv = "",
    passv = "",
    tokv = "";
var userlogin = false;
var userinfo,
    gevents;

function getEvents() {
    let headers = new Headers();
    headers.append('Authorization', 'Basic ' + tokv);
    httpDo("../auth/events", {
        method: 'POST',
        headers: headers,
    }, function (data) {
        gevents = JSON.parse(data);
    }, function () {
        showMessage("Ошибка получения списка событий!", "error");
    });
}

function getMyEvents() {
    if (eventselect != 2) {
        if (userinfo.User.Events) {
            eventselect = 2;
            events.Events = userinfo.User.Events;
            maxEvent = Math.round(events.Events.length / 10 + 0.5);
            nextEvent = 0;
            refreshEvents();
            if (select("#eventpanel").class().indexOf("hide") > -1)
                showWindow("#eventpanel");
            if (select("#saveevents").class().indexOf("evbtnhide") > -1)
                select("#saveevents").removeClass("evbtnhide");
            if ((select("#createevent").class().indexOf("evbtnhide") > -1) && (userinfo.Type == "Организатор"))
                select("#createevent").removeClass("evbtnhide");
        }
    } else {
        leaveWindow("#eventpanel");
        eventselect = 0;
    }
}

function showCrEvent(t) {
    if (t == -1) {
        crevent = -1;
        if (select("#evmenu").class().indexOf("hide") > -1) {
            select("#evmenu_titlebar").html("Создать событие");
            select("#evmenu_submit").value("Создать");
            select("#evmenu_title").value("");
            let d = new Date();
            select("#evmenu_year").value(d.getFullYear());
            showWindow("#evmenu");
        } else leaveWindow("#evmenu");
    } else {
        crevent = t;
        if (select("#evmenu").class().indexOf("hide") > -1) {
            select("#evmenu_titlebar").html("Изменить событие");
            select("#evmenu_submit").value("Изменить");
            let tevent = userinfo.User.Events[t];
            select("#evmenu_title").value(tevent.Title);
            select("#evmenu_level").value(tevent.Level);
            select("#evmenu_year").value(tevent.Year);
            showWindow("#evmenu");
        } else leaveWindow("#evmenu");
    }
}

function showStEvent(t) {
    if (select("#studentpanel").class().indexOf("hide") > -1) {
        showWindow("#studentpanel");
    }
}

function refreshStudents(p) {
    if (p == -1) {
        if (nextStudent > 0) nextStudent--;
    }
    if (p == 1) {
        if (nextStudent < maxStudent - 1) nextStudent++;
    }
    let levels = ["Городской", "Региональный", "Всероссийский", "Международный"];
    let evtitle, evlevel, gen;
    let imax;
    if (nextEvent < maxEvent) imax = nextEvent * 10 + 10;
    else
        imax = nextEvent * 10 + events.length - maxEvent * 10;
    let cev = select("#events");
    cev.html("");
    let page = select("#eventpage");
    page.html("Стр." + (nextEvent + 1));
    for (let i = nextEvent * 10; i < nextEvent * 10 + 10; i++) {
        if (events.Events[i]) {
            evtitle = events.Events[i].Title;
            if (evtitle.length > 35) evtitle = evtitle.substring(0, 35) + "...";
            evlevel = levels[events.Events[i].Level - 1];
            if ((userinfo.Type == "Организатор") && (eventselect == 2))
                gen = "<div class='event' onclick='showCrEvent(" + i + ")'>";
            else
            if ((userinfo.Type != "Обучающийся") && (eventselect == 1))
                gen = "<div class='event' onclick='showStEvent(" + i + ")'>";
            else
                gen = "<div class='event'>";
            gen = gen + "<div class='punkt1'>" +
                evtitle + "</div><div class='punkt2'>" +
                evlevel + "</div><div class='punkt3'>" +
                events.Events[i].Year + "</div><div class='punktorg'>" +
                events.Events[i].Organizer + "</div><div class='punktst'>" +
                events.Events[i].Students + "</div></div>";
            if (eventselect == 1) {
                if (userinfo.Type == "Обучающийся") gen += "<div class='btn btnadd' onclick=\"addEvent(" + i + ")\">✚</div>";
            }
            if (eventselect == 2) {
                gen += "<div class='btn btndel' onclick=\"delEvent(" + i + ")\">✕</div>";
            }
            cev.html(cev.html() + gen);
        } else break;
    }
}

function createEventOrg() {
    if (crevent == -1) {
        let ev = {};
        ev.Title = select("#evmenu_title").value();
        ev.Level = select("#evmenu_level").value();
        ev.Year = select("#evmenu_year").value();
        ev.Organizer = "Вы";
        ev.Students = [];
        userinfo.User.Events.push(ev);
        sa_scrollymax = 190 * userinfo.User.Events.length;
        //events.Events = userinfo.User.Events;
        //maxEvent = Math.round(events.Events.length / 10 + 0.5);
        //nextEvent = maxEvent - 1;
        //refreshEvents();
        showMessage("Успешно! Событие было создано.", "success");
    } else {
        if (userinfo.User.Events[crevent]) {
            let ev = {};
            ev.Title = select("#evmenu_title").value();
            ev.Level = select("#evmenu_level").value();
            ev.Year = select("#evmenu_year").value();
            let tevent = userinfo.User.Events[crevent];
            tevent.Title = ev.Title;
            tevent.Level = ev.Level;
            tevent.Year = ev.Year;
            //leaveWindow("#evmenu");
            //events.Events = userinfo.User.Events;
            //maxEvent = Math.round(events.Events.length / 10 + 0.5);
            //nextEvent = maxEvent - 1;
            //refreshEvents();
            showMessage("Успешно! Событие было изменено.", "success");
        } else {
            showMessage("Событие было удалено или не существовало.", "error");
        }
    }
}

function addEvent(eid) {
    let addev = true;
    let tevent = gevents.Events[eid];
    for (let i = 0; i < userinfo.User.Events.length; i++) {
        if (userinfo.User.Events[i].Id == tevent.Id) addev = false;
    }
    if (addev) {
        userinfo.User.Events.push(tevent);
        showMessage("Успешно!", "success");
    } else {
        showMessage("Это событие уже есть в вашем списке!", "error");
    }
}

function delEvent(eid) {
    let delev = true;
    let tevent = userinfo.User.Events[eid];
    for (let i = 0; i < userinfo.User.DelEvents.length; i++) {
        if ((userinfo.User.DelEvents[i].Id == tevent.Id) && (tevent.Id)) delev = false;
    }
    if (tevent) {
        if ((delev) && (tevent.Id)) userinfo.User.DelEvents.push(tevent.Id);
        userinfo.User.Events.splice(eid, 1);
        //events.Events = userinfo.User.Events;
        //maxEvent = Math.round(events.Events.length / 10 + 0.5);
        //refreshEvents();
        showMessage("Успешно!", "success");
        sa_scrollymax = 190 * userinfo.User.Events.length;
    } else {
        showMessage("Вы пытаетесь удалить несуществующее событие!", "error");
    }
}

function refreshEvents(p) {
    if (p == -1) {
        if (nextEvent > 0) nextEvent--;
    }
    if (p == 1) {
        if (nextEvent < maxEvent - 1) nextEvent++;
    }
    let levels = ["Городской", "Региональный", "Всероссийский", "Международный"];
    let evtitle, evlevel, gen;
    let imax;
    if (nextEvent < maxEvent) imax = nextEvent * 10 + 10;
    else
        imax = nextEvent * 10 + events.length - maxEvent * 10;
    let cev = select("#events");
    cev.html("");
    let page = select("#eventpage");
    page.html("Стр." + (nextEvent + 1));
    for (let i = nextEvent * 10; i < nextEvent * 10 + 10; i++) {
        if (events.Events[i]) {
            evtitle = events.Events[i].Title;
            if (evtitle.length > 35) evtitle = evtitle.substring(0, 35) + "...";
            evlevel = levels[events.Events[i].Level - 1];
            if ((userinfo.Type == "Организатор") && (eventselect == 2))
                gen = "<div class='event' onclick='showCrEvent(" + i + ")'>";
            else
            if ((userinfo.Type != "Обучающийся") && (userinfo.Type != "Организатор") && (eventselect == 1))
                gen = "<div class='event' onclick='showStEvent(" + i + ")'>";
            else
                gen = "<div class='event'>";
            gen = gen + "<div class='punkt1'>" +
                evtitle + "</div><div class='punkt2'>" +
                evlevel + "</div><div class='punkt3'>" +
                events.Events[i].Year + "</div><div class='punktorg'>" +
                events.Events[i].Organizer + "</div><div class='punktst'>";
            if (userinfo.Type == "Обучающийся" || ((userinfo.Type == "Организатор") && (eventselect == 1)))
                gen = gen + events.Events[i].Students + "</div></div>";
            else
                gen = gen + events.Events[i].Students.length + "</div></div>";
            if (eventselect == 1) {
                if (userinfo.Type == "Обучающийся") gen += "<div class='btn btnadd' onclick=\"addEvent(" + i + ")\">✚</div>";
            }
            if (eventselect == 2) {
                gen += "<div class='btn btndel' onclick=\"delEvent(" + i + ")\">✕</div>";
            }
            cev.html(cev.html() + gen);
        } else break;
    }
}

function exitClick() {
    if ((getCook("logv")) && (getCook("tokv"))) {
        delCook("logv");
        delCook("tokv");
        logv = "";
        passv = "";
        tokv = "";
        userlogin = false;
        doUserAction("exit");
    }
}

function logClick() {
    logv = select("#menu_login").value();
    passv = select("#menu_password").value();
    if ((logv) && ((passv) || (tokv))) {
        let headers = new Headers();
        if (!tokv) tokv = btoa("sa_" + logv + ":" + passv);
        headers.append('Authorization', 'Basic ' + tokv);
        httpDo("../auth/", {
            method: 'POST',
            headers: headers,
        }, function (data) {
            if ((!getCook("logv")) && (!getCook("tokv"))) {
                showMessage("Успех!", "success");
                leaveWindow("#regmenu");
                document.cookie = "logv=" + logv;
                document.cookie = "tokv=" + tokv;
                passv = "";
                doUserAction("login", data);
                let lm = loginmenu.slr.child().item(0);
                toggleClass(lm, "show");
                //location = '/gui/index.html';
            }
        }, function (data) {
            tokv = "";
            showMessage("Ошибка входа! Неверное имя пользователя или пароль.", "error");
        });
    }
}

function getForm(formid) {
    let inform = select("form", "#" + formid);
    let childs = inform.child();
    var out = {};
    for (let i = 0; i < childs.length; i++) {
        if (childs.item(i).name) {
            if ("City Street Home".indexOf(childs.item(i).name) > -1) {
                if (!out.Address) out.Address = {};
                out.Address[childs.item(i).name] = childs.item(i).value;
            } else {
                if (childs.item(i).name == "Phones")
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

function regClick(formid) {
    if ((!logv) && (!tokv)) {
        let jsonobj = getForm(formid);
        httpPost("../reg", "text", jsonobj, function (data) {
            showMessage("Вы успешно зарегистрировались!", "success");
            leaveWindow("#regmenu");
        }, function (data) {
            showMessage("Произошла ошибка во время регистрации.", "error");
        });
    }
}

function leftbarp(ptext, i) {
    fill(16, 64);
    sa_rect(0, 30 * i, width * 0.12, 30, function () {
        cursor(HAND);
        if (i == 0) {
            if (userinfo.Type == "Организатор" && select("#evmenu").class().indexOf("hidefull") > -1) {
                select("#evmenu").removeClass("hidefull");
            }
            if (userinfo.Type != "Работодатель") {
                sa_scrollymax = 190 * userinfo.User.Events.length;
            } else sa_scrollymax = 1;
        }
        if (i == 1) {
            eventsbar();
            if (select("#evmenu").class().indexOf("hidefull") == -1) {
                select("#evmenu").addClass("hidefull");
            }
        }
        gslide = i;
    }, function () {
        cursor(HAND);
        fill(16, 128);
    });
    fill(255);
    text(ptext, 5, 30 * i + 20);
}

function leftbar() {
    sa_push();
    sa_translate(width * 0.2, 60);
    textAlign(LEFT);
    textSize(18);
    leftbarp("Главная", 0);
    leftbarp("События", 1);
    //leftbarp("Достижения", 2);
    sa_pop();
}

function logobar() {
    sa_push();
    fill(255);
    rect(width * 0.2 + width * 0.12 + 10, 60, width * 0.16, width * 0.16 * 1.2);
    stroke(196);
    rect(width * 0.2 + width * 0.12 + 19, 69, width * 0.16 - 18, width * 0.16 * 1.2 - 18);
    //if (logoimg) image(logoimg, width * 0.2 + width * 0.12 + 20, 70, width * 0.16 - 20, width * 0.16 * 1.2 - 20);
    const w = width * 0.16 - 20;
    const h = width * 0.16 * 1.2 - 20;
    const wdh = w / h;
    if (logoimg)
        copy(logoimg, logoimg.width / 2 - w / 2, 0, w, h, width * 0.2 + width * 0.12 + 20, 70, w, h);
    sa_pop();
}

function rightbar() {
    sa_push();
    sa_translate(width * 0.2 + width * 0.12 + width * 0.16 + 20, 60);
    fill(255);
    //stroke(196);
    rect(0, 0, width * 0.3, width * 0.16 * 1.2);
    textSize(18);
    fill(0);
    if (userinfo.Type == "Обучающийся") {
        text(userinfo.User.Surname + " " + userinfo.User.Name + " (Обучающийся)", 15, 30);
        textSize(14);
        fill(64);
        text("Электронная почта:", 15, 70);
        text("День рождения:", 15, 95);
        text("Город:", 15, 120);
        text("Улица:", 15, 145);
        text("Дом:", 15, 170);
        fill(0);
        text(userinfo.User.Email, 170, 70);
        text(userinfo.User.ShowBirthday, 170, 95);
        text(userinfo.User.Address.City, 170, 120);
        text(userinfo.User.Address.Street, 170, 145);
        text(userinfo.User.Address.Home, 170, 170);
    }
    if (userinfo.Type == "Организатор") {
        text(userinfo.User.Title + " (Организатор)", 15, 30);
        textSize(14);
        fill(64);
        text("Электронная почта:", 15, 70);
        text("Телефоны:", 15, 95);
        text("Город:", 15, 120);
        text("Улица:", 15, 145);
        text("Дом:", 15, 170);
        fill(0);
        text(userinfo.User.Email, 170, 70);
        text(userinfo.User.Phones, 170, 95);
        text(userinfo.User.Address.City, 170, 120);
        text(userinfo.User.Address.Street, 170, 145);
        text(userinfo.User.Address.Home, 170, 170);
    }
    if (userinfo.Type == "Работодатель") {
        text(userinfo.User.Title + " (Работодатель)", 15, 30);
        textSize(14);
        fill(64);
        text("ФИО Руководителя:", 15, 70);
        text("Электронная почта:", 15, 95);
        text("Телефоны:", 15, 120);
        text("Город:", 15, 145);
        text("Улица:", 15, 170);
        text("Дом:", 15, 195);
        fill(0);
        text(userinfo.User.Chief, 170, 70);
        text(userinfo.User.Email, 170, 95);
        text(userinfo.User.Phones, 170, 120);
        text(userinfo.User.Address.City, 170, 145);
        text(userinfo.User.Address.Street, 170, 170);
        text(userinfo.User.Address.Home, 170, 195);
    }
    stroke(196);
    line(5, 45, width * 0.3 - 5, 45);
    sa_pop();
}

function showevent(i, m, j) {
    let h = 0;
    if (j != i) h = 180;
    else if (userinfo.Type != "Работодатель") h = 180 + 30 + userinfo.User.Events[i].Students.length * 30;
    else h = 180 + 30 + gevents.Events[i].Students.length * 30;
    if ((sa_transy < height) && (sa_transy + h > 50)) {
        fill(255);
        let w = width * 0.16 + 10 + width * 0.3;
        let levels = ["Городское", "Региональное", "Всероссийское", "Международное"];
        rect(0, 0, w, h);
        stroke(196);
        textSize(16);
        fill(64);
        text("Название события:", 25, 60);
        text("Тип события:", 25, 90);
        text("Год проведения:", 25, 120);
        text("Участников:", 25, 150);
        fill(0);
        if (m) {
            text(userinfo.User.Events[i].Title, w / 2, 60);
            text(levels[userinfo.User.Events[i].Level - 1], w / 2, 90);
            text(userinfo.User.Events[i].Year, w / 2, 120);
            if (userinfo.Type != "Организатор") text(userinfo.User.Events[i].Students, w / 2, 150);
            else text(userinfo.User.Events[i].Students.length, w / 2, 150);
            textStyle(BOLD);
            text(userinfo.User.Events[i].Organizer, 15, 33);
            textStyle(NORMAL);
            noStroke();
            let addy = 0;
            if (userinfo.Type == "Организатор") addy = 183;
            if (j != -1 && j < i) addy += 30 + userinfo.User.Events[j].Students.length * 30;
            textSize(14);
            if (userinfo.Type != "Обучающийся") {
                fill(196);
                sa_text("Показать участников", w - 180, 25, function () {
                    if (gshst != i) gshst = i;
                    else gshst = -1;
                }, function () {
                    fill(46, 143, 229);
                    cursor(HAND);
                });
            }
            fill(196);
            sa_text("X", w - 25, 25, function () {
                delEvent(i);
            }, function () {
                fill(229, 46, 46);
                cursor(HAND);
            });
            if (j == i) {
                sa_push();
                fill(0);
                textStyle(BOLD);
                text("Фамилия", 25, 190);
                text("Имя", 165, 190);
                text("Электр. почта", 285, 190);
                text("Год рождения", 465, 190);
                textStyle(NORMAL);
                if (userinfo.User.Events[i].Students.length > 0) {
                    for (let st = 0; st < userinfo.User.Events[i].Students.length; st++) {
                        text(userinfo.User.Events[i].Students[st].Surname, 25, 220);
                        text(userinfo.User.Events[i].Students[st].Name, 165, 220);
                        text(userinfo.User.Events[i].Students[st].Email, 285, 220);
                        let birthday = userinfo.User.Events[i].Students[st].Birthday.split("-");
                        text(birthday[0], 465, 220);
                        sa_translate(0, 30);
                    }
                }
                sa_pop();
            }
        } else {
            text(gevents.Events[i].Title, w / 2, 60);
            text(levels[gevents.Events[i].Level - 1], w / 2, 90);
            text(gevents.Events[i].Year, w / 2, 120);
            if (userinfo.Type != "Работодатель") text(gevents.Events[i].Students, w / 2, 150);
            else text(gevents.Events[i].Students.length, w / 2, 150);
            textStyle(BOLD);
            text(gevents.Events[i].Organizer, 15, 30);
            textStyle(NORMAL);
            noStroke();
            //fill(0);
            //rect(w - 25, 190*i+5, 20, 20);
            if (userinfo.Type == "Обучающийся") {
                fill(196);
                sa_text("+", w - 25, 25, function () {
                    addEvent(i);
                }, function () {
                    fill(46, 143, 229);
                    cursor(HAND);
                });
            }
            if (userinfo.Type == "Работодатель") {
                let addy = 0;
                if (j != -1 && j < i) addy += 30 + gevents.Events[j].Students.length * 30;
                textSize(14);
                fill(196);
                sa_text("Показать участников", w - 160, 25, function () {
                    if (gshst != i) gshst = i;
                    else gshst = -1;
                }, function () {
                    fill(46, 143, 229);
                    cursor(HAND);
                });
                if (j == i) {
                    sa_push();
                    fill(0);
                    textStyle(BOLD);
                    text("Фамилия", 25, 190);
                    text("Имя", 165, 190);
                    text("Электр. почта", 285, 190);
                    text("Год рождения", 465, 190);
                    textStyle(NORMAL);
                    if (gevents.Events[i].Students.length > 0) {
                        for (let st = 0; st < gevents.Events[i].Students.length; st++) {
                            text(gevents.Events[i].Students[st].Surname, 25, 220);
                            text(gevents.Events[i].Students[st].Name, 165, 220);
                            text(gevents.Events[i].Students[st].Email, 285, 220);
                            let birthday = gevents.Events[i].Students[st].Birthday.split("-");
                            text(birthday[0], 465, 220);
                            sa_translate(0, 30);
                        }
                    }
                    sa_pop();
                }
            }
        }
        textSize(10);
        fill(64);
        text(i + 1, 5, 15);
    }
    if (j != i) sa_translate(0, 190);
    else if (userinfo.Type != "Работодатель") sa_translate(0, 190 + 30 + userinfo.User.Events[i].Students.length * 30);
    else sa_translate(0, 190 + 30 + gevents.Events[i].Students.length * 30);
    noStroke();
}

function myeventsbar() {
    sa_push();
    sa_translate(width * 0.2 + width * 0.12 + 10, width * 0.16 * 1.2 + 70);
    fill(255);
    //stroke(196);
    rect(0, 0, width * 0.16 + 10 + width * 0.3, 50);
    textSize(16);
    textStyle(BOLD);
    fill(64);
    text("Мои события", 15, 30);
    textStyle(NORMAL);
    sa_text("Сохранить изменения", width * 0.16 + 10 + width * 0.3 - 200, 30, function () {
        saveUser();
    }, function () {
        cursor(HAND);
        fill(46, 143, 229);
    });
    stroke(196);
    line(0, 49, width * 0.16 + 10 + width * 0.3, 49);
    if (userinfo.Type == "Организатор") sa_translate(0, 235);
    else sa_translate(0, 50);
    noStroke();
    for (let i = 0; i < userinfo.User.Events.length; i++) showevent(i, true, gshst);
    sa_scrollymax = sa_transy + Math.abs(sa_scrolly) - 570;
    sa_pop();
}

function showeventsbar() {
    if (gevents) {
        sa_push();
        sa_translate(width * 0.2 + width * 0.12 + 10, 60);
        fill(255);
        //stroke(196);
        rect(0, 0, width * 0.16 + 10 + width * 0.3, 50);
        textSize(16);
        textStyle(BOLD);
        fill(128);
        text("Все события", 15, 30);
        textStyle(NORMAL);
        stroke(196);
        line(0, 49, width * 0.16 + 10 + width * 0.3, 49);
        sa_translate(0, 50);
        noStroke();
        for (let i = 0; i < gevents.Events.length; i++) showevent(i, false, gshst);
        sa_scrollymax = sa_transy + Math.abs(sa_scrolly) - 570;
        sa_pop();
    }
}

function eventsbar() {
    let headers = new Headers();
    headers.append('Authorization', 'Basic ' + tokv);
    httpDo("../auth/events", {
        method: 'POST',
        headers: headers,
    }, function (data) {
        gevents = JSON.parse(data);
        sa_scrollymax = 190 * gevents.Events.length - 190;
        if (sa_scrollymax < 0) sa_scrollymax = 0;
    }, function () {
        showMessage("Ошибка получения списка событий!", "error");
    });
}

var topbar, loginmenu, regmenu, cmessage, cevents, cstudents, evmenu, messageId = 0;
var logoimg;

function preload() {
    topbar = new Component("topbar");
    loginmenu = new Component("loginmenu");
    regmenu = new Component("regmenu");
    cmessage = new Component("message");
    evmenu = new Component("evmenu");
    topbar.init(toggleTopbar);
    loginmenu.init();
    regmenu.init();
    cmessage.init("", ["", "", "", ""]);
    evmenu.init(function () {
        select("#evmenu").position(windowWidth * 0.2 + windowWidth * 0.12 + 10, windowWidth * 0.16 * 1.2 + 120);
        select("#evmenu").size(windowWidth * 0.16 + 10 + windowWidth * 0.3, 175);
        select(".filestream").position(width * 0.2 + width * 0.12 + 20, 70);
        select(".filestream").size(width * 0.16 - 20, width * 0.16 * 1.2 - 20);
    });
}

var canvas, gslide = 0,
    gshst = -1;
var nextEvent = 0,
    maxEvent = 0,
    eventselect = 0,
    crevent = -1;
var nextStudent = 0,
    maxStudent = 0;

var redrawv = false,
    mainint;

function setup() {
    canvas = createCanvas(windowWidth, windowHeight);
    canvas.parent("interface");
    canvas.style("position", "fixed");
    canvas.style("left", "0px");
    canvas.style("top", "0px");
    canvas.style("z-index", "-999");
    fill(255);
    noStroke();
    noLoop();
    var mainint = setInterval(function () {
        redraw();
    }, 15);
}

function uploadLogoImg() {
    let inp = document.getElementsByClassName("filestream")[0].files[0];
    let inptype = inp.type.split("/");
    if (inp.size <= 512000 && inptype[0] == "image" && (inptype[1] == "jpeg" || inptype[1] == "png")) {
        let headers = new Headers();
        headers.append('Authorization', 'Basic ' + tokv);
        let formData = new FormData(document.getElementById("filestream"));
        httpDo("../auth/savelogo", {
            method: 'POST',
            headers: headers,
            body: formData
        }, function (data) {
            showMessage("Изображение успешно обновлено.", "success");
        }, function (data) {
            showMessage("Не соответствует формату (jpeg, png) или размер изображения > 500 килобайт.", "error");
        });
    } else showMessage("Не соответствует формату (jpeg, png) или размер изображения > 500 килобайт.", "error");
}

function draw() {
    clear();
    cursor(ARROW);
    if (redrawv) {
        fill(0);
        //text(Math.abs(sa_scrolly), 50, 150);
        //text(sa_scrollymax, 50, 350);
        sa_clearTranslate();
        leftbar();
        if (gslide == 0) {
            if (userinfo) {
                logobar();
                rightbar();
                if (userinfo.Type != "Работодатель") myeventsbar();
            }
        } else showeventsbar();
    }
}

function mousePressed() {
    if (mouseButton == LEFT) {
        if (sa_gclick != -1) sa_gclick = 1;
    }
}

function mouseReleased() {
    sa_gclick = 0;
}

function mouseWheel(event) {
    sa_scrolly -= event.delta * 15;
    if (sa_scrolly > 0) sa_scrolly = 0;
    if (sa_scrollymax < Math.abs(sa_scrolly)) sa_scrolly = -sa_scrollymax;
    select("#evmenu").position(width * 0.2 + width * 0.12 + 10, width * 0.16 * 1.2 + 120 + sa_scrolly);
    select(".filestream").position(width * 0.2 + width * 0.12 + 20, 70 + sa_scrolly);
    return false;
}

function windowResized() {
    resizeCanvas(windowWidth, windowHeight);
    select("#evmenu").position(width * 0.2 + width * 0.12 + 10, width * 0.16 * 1.2 + 120);
    select("#evmenu").size(width * 0.16 + 10 + width * 0.3, 175);
    select(".filestream").position(width * 0.2 + width * 0.12 + 20, 70);
    select(".filestream").size(width * 0.16 - 20, width * 0.16 * 1.2 - 20);
}