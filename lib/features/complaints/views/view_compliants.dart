import 'package:flutter/material.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/functions/date_time.dart';
import 'package:residency_desktop/features/complaints/data/complaints.model.dart';

class ViewComplaints extends StatelessWidget {
  const ViewComplaints({super.key, required this.complaint});
  final ComplaintsModel complaint;

  @override
  Widget build(BuildContext context) {
    return _desktopViewComplaints(complaint: complaint);
  }

  Widget _desktopViewComplaints({required ComplaintsModel complaint}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complaints'.toUpperCase(),
                  style:
                      getTextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: Text(
                    'Title: ',
                    style:
                        getTextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      complaint.title ?? '',
                      style: getTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                    style:
                        getTextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      complaint.description ?? '',
                      style: getTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            complaint.type ?? '',
                            style: getTextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            complaint.severity ?? '',
                            style: getTextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: complaint.status!.toLowerCase() ==
                                          'pending'
                                      ? Colors.black45
                                      : complaint.status!.toLowerCase() ==
                                              'in progress'
                                          ? Colors.yellow
                                          : complaint.status!.toLowerCase() ==
                                                  'resolved'
                                              ? Colors.green
                                              : Colors.red,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  complaint.status ?? '',
                                  style: getTextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
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
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            DateTimeAction.getDateTime(complaint.createdAt!),
                            style: getTextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
              margin: const EdgeInsets.symmetric(horizontal: 20),
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student'.toUpperCase(),
                  style:
                      getTextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        image: NetworkImage(
                          complaint.studentImage ?? '',
                        ),
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
                    style:
                        getTextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      complaint.studentId ?? '',
                      style: getTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                    style:
                        getTextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      complaint.studentName ?? '',
                      style: getTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            complaint.studentPhone ?? '',
                            style: getTextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            complaint.roomNumber ?? '',
                            style: getTextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )),
            if (complaint.images != null && complaint.images!.isNotEmpty)
              Container(
                width: 3,
                height: 300,
                color: Colors.black12,
                margin: const EdgeInsets.symmetric(horizontal: 25),
              ),
            if (complaint.images != null && complaint.images!.isNotEmpty)
              SizedBox(
                  width: 200,
                  child: Column(
                    children: [
                      Text(
                        'Images'.toUpperCase(),
                        style: getTextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      for (var e in complaint.images!)
                        Container(
                          height: 100,
                          width: 100,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(
                                e,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                    ],
                  )),
          ],
        ),
      ],
    );
  }
}
