function format_Date(dy) {
//	var dy = begin_date.selectedDate;
	var mm = dy.getMonth() + 1;
	var dd = dy.getDate();
	var yyyy = dy.getFullYear();
	var fmt_bdt = mm + '/' + dd + '/' + yyyy;
	return fmt_bdt;
}
