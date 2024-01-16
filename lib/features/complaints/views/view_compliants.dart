import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/functions/date_time.dart';
import 'package:residency_desktop/core/widgets/custom_button.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/features/complaints/data/complaints.model.dart';

class ViewComplaints extends StatelessWidget {
  const ViewComplaints({super.key, required this.complaint});
  final ComplaintsModel complaint;

  @override
  Widget build(BuildContext context) {
    return _desktopViewComplaints(complaint: complaint);
  }

  Widget _desktopViewComplaints({required ComplaintsModel complaint}) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complaints'.toUpperCase(),
                          style: getTextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          title: Text(
                            'Title: ',
                            style: getTextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              complaint.title ?? '',
                              style: getTextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          title: Text(
                            'Description: ',
                            style: getTextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              complaint.description ?? '',
                              style: getTextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        //type
                        Row(
                          children: [
                            SizedBox(
                              width: 180,
                              child: ListTile(
                                title: Text(
                                  'Type: ',
                                  style: getTextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    complaint.type ?? '',
                                    style: getTextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            //severity
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  'Severity: ',
                                  style: getTextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    complaint.severity ?? '',
                                    style: getTextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            //location
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  'Location: ',
                                  style: getTextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${complaint.location} ${complaint.location!.toLowerCase().contains('my') ? '(${complaint.roomNumber})' : ''}',
                                    style: getTextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        //status
                        Row(
                          children: [
                            SizedBox(
                              width: 180,
                              child: ListTile(
                                title: Text(
                                  'Status: ',
                                  style: getTextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: complaint.status!
                                                      .toLowerCase() ==
                                                  'pending'
                                              ? Colors.black45
                                              : complaint.status!
                                                          .toLowerCase() ==
                                                      'in progress'
                                                  ? Colors.yellow
                                                  : complaint.status!
                                                              .toLowerCase() ==
                                                          'resolved'
                                                      ? Colors.green
                                                      : Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          complaint.status ?? '',
                                          style: getTextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            //created at
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  'Created At: ',
                                  style: getTextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    DateTimeAction.getDateTime(
                                        complaint.createdAt!),
                                    style: getTextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                Container(
                  width: 3,
                  height: 300,
                  color: Colors.black12,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                ),
                SizedBox(
                    width: 320,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student'.toUpperCase(),
                          style: getTextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        //student Image
                        if (complaint.studentImage != null &&
                            complaint.studentImage!.isNotEmpty)
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: MemoryImage(base64Decode(
                                  complaint.studentImage ?? '',
                                )),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          title: Text(
                            'Student ID: ',
                            style: getTextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              complaint.studentId ?? '',
                              style: getTextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          title: Text(
                            'Student Name: ',
                            style: getTextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              complaint.studentName ?? '',
                              style: getTextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ListTile(
                                title: Text(
                                  'Student Phone: ',
                                  style: getTextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    complaint.studentPhone ?? '',
                                    style: getTextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            //room no
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  'Room No: ',
                                  style: getTextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    complaint.roomNumber ?? '',
                                    style: getTextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                // if (complaint.images != null && complaint.images!.isNotEmpty)
                //   Container(
                //     width: 3,
                //     height: 300,
                //     color: Colors.black12,
                //     margin: const EdgeInsets.symmetric(horizontal: 25),
                //   ),
                // if (complaint.images != null && complaint.images!.isNotEmpty)
                //   SizedBox(
                //       width: 200,
                //       child: Column(
                //         children: [
                //           Text(
                //             'Images'.toUpperCase(),
                //             style: getTextStyle(
                //                 fontSize: 18, fontWeight: FontWeight.bold),
                //           ),
                //           const SizedBox(
                //             height: 10,
                //           ),
                //           for (var e in complaint.images!)
                //             Container(
                //               height: 100,
                //               width: 100,
                //               margin: const EdgeInsets.all(5),
                //               decoration: BoxDecoration(
                //                 borderRadius: BorderRadius.circular(10),
                //                 image: DecorationImage(
                //                   image: NetworkImage(
                //                     e,
                //                   ),
                //                   fit: BoxFit.cover,
                //                 ),
                //               ),
                //             )
                //         ],
                //       )),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            //close button
            SizedBox(
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                      text: 'Close',
                      color: Colors.red,
                      radius: 5,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      icon: Icons.close,
                      onPressed: () {
                        CustomDialog.dismiss();
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
