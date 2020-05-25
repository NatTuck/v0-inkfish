
/*
  Grade Table:

  {
    cols: [{id, name, weight}]
    rows: [{name, grades: [{raw_grade, grade}]}]
  }


  Tweaks:

   {
     tmin:  Num,
     tmax:  Num,
     scale: Num,
     curve: { mean: Num, std: Num },
   }


 */

import { Decimal } from 'decimal.js';
import _ from 'lodash';

export function bucket_table(sheet, bucket_id) {
  let bucket = sheet.buckets.find((bb) => bb.id == bucket_id);
  let cols = _.sortBy(bucket.assignments, (as) => as.name);
  let rows = sheet.students.map((stu) => {
    let subs = sheet.grades.filter((gr) => gr.reg_id == stu.id);
    let grades = cols.map((as) => {
      let gr = subs.find((gr) => gr.as_id == as.id);
      return { grade: new Decimal(gr.grade || "0") };
    });
    return { id: stu.id, name: stu.name, grades: grades };
  });
  return { rows, cols };
}

export function total_table(sheet) {

}
