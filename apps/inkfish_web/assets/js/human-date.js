
import moment from "moment";

export default function init_dates() {
  $('.human-date').each((_ii, elem) => {
    let text = elem.innerText;
    let date = moment(text, "YYYY-MM-DD HH:mm:ss");
    let human_date = date.format('dddd, YYYY-MMM-DD');
    let human_time = date.format('HH:mm');
    let rel_date = date.fromNow();
    elem.innerText = `${human_date} at ${human_time}; ${rel_date}`;
    $(elem).removeClass('human-date');
  });
}
