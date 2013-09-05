/*
 * table sorter - jquery.tablesorter.js
 * table pagination - jquery by rfang
 * all under GPL licenses.
 */

$(document).ready(function(){
    $("#tbl_data").tablesorter({
        sortList:[[0,0]], widgets: ['zebra']
    });

    function cal_page() {
        page = (length % pageSize) == 0 ? (length / pageSize)
            : Math.floor(length / pageSize) + 1;
    }

    function show_page() {
        currentPage += direct;
        if (currentPage <= 0 || currentPage > page) {
            currentPage -= direct;
            return;
        }

        $("#pagination input").val(currentPage + "/" + page);

        var begin = (currentPage - 1) * pageSize;
        var end = Number(begin) + Number(pageSize);
        if (end > length) {
            end = length;
        }

        $("#tbl_data tbody tr").hide();

        var tag = true;
        $("#tbl_data tbody tr").each(function(i) {
            if (i >= begin && i < end) {
                $(this).show();
                if (tag) {
                    $(this).removeClass().addClass("odd");
                }
                else {
                    $(this).removeClass().addClass("even");
                }
                tag = !tag;
            }
        });
    }

    var pageSize = $("#pagination select option[selected]").val();
    var currentPage = 1;
    var direct = 0;
    var length = $("#tbl_data tbody tr").length;
    var page;
    var all = false;

    cal_page();

    currentPage = 1;
    show_page();


    $("#pagination select").change(function() {
        var sz = $(this).children('option:selected').val();
        pageSize = sz;
        currentPage = 1;
        direct = 0;

        cal_page();
        show_page();
    });

    $("#pagination a").each(function(i) {
        $(this).click(function() {
            switch (i)
            {
                case 0:
                    currentPage = 1;
                    direct = 0;
                    show_page();
                    break;
                case 1:
                    direct = -1;
                    show_page();
                    break;
                case 2:
                    direct = 1;
                    show_page();
                    break;
                case 3:
                    currentPage = page;
                    direct = 0;
                    show_page();
                    break;
                case 4:
                    currentPage = 1;
                    direct = 0;
                    if (!all) {
                        pageSize = length;
                        page = 1;
                        all = !all;
                    }
                    else {
                        pageSize = $("#pagination select option[selected]").val();
                        cal_page();
                        all = !all;
                    }
                    show_page();
                    break;
            }

            return false;
        });
    });
});