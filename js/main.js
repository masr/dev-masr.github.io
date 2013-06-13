$(function () {
    $.fn.tagcloud.defaults = {
        size:{start:0.9, end:2, unit:'em'},
        color:{start:'#777', end:'#a00'}
    };
    $('#tag_cloud a').tagcloud();


    $(".post #content").css('min-height', $("#sidebar").height() + 90 + 'px');

    $("#post .excerpt").addClass("table-bordered");
});