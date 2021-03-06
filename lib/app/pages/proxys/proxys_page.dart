import 'package:clash_for_flutter/app/bean/group_bean.dart';
import 'package:clash_for_flutter/app/enum/type_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:clash_for_flutter/app/bean/history_bean.dart';
import 'package:clash_for_flutter/app/bean/proxy_bean.dart';
import 'package:clash_for_flutter/app/component/drawer_component.dart';
import 'package:clash_for_flutter/app/component/loading_component.dart';
import 'package:clash_for_flutter/app/pages/proxys/proxys_controller.dart';
import 'package:asuka/asuka.dart' as asuka;

/// 代理配置页
class ProxysPage extends StatefulWidget {
  @override
  _ProxysPageState createState() => _ProxysPageState();
}

class _ProxysPageState extends ModularState<ProxysPage, ProxysController> {
  @override
  void initState() {
    controller.init();
    super.initState();
  }

  void testDelay(TabController _tabController) async {
    var overlay = Loading.builder();
    asuka.addOverlay(overlay);
    await controller.delayGroup(
      controller.model.groups[_tabController.index],
    );
    overlay.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      var groups = controller.model.groups;
      var providers = controller.model.providers;
      return DefaultTabController(
        length: groups.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text("代理"),
            bottom: TabBar(
              tabs: groups.map((e) => Tab(text: e.name)).toList(),
              isScrollable: true,
            ),
          ),
          drawer: AppDrawer(),
          body: TabBarView(
            children: groups.map((group) {
              var groupName = group.name;
              var groupNow = group.now;
              var proxies = providers[groupName]?.proxies ?? [];
              return ListView.separated(
                separatorBuilder: (con, i) => Divider(height: 5),
                itemCount: proxies.length,
                itemBuilder: (con, i) {
                  var proxie = proxies[i];
                  var proxieName = proxie.name;
                  var historys = proxie.history as List<History>;
                  var delay = historys.isNotEmpty
                      ? Text(
                          historys.last.delay > 0
                              ? historys.last.delay.toString()
                              : "timeout",
                        )
                      : null;
                  var subText = proxie is Proxy
                      ? proxie.type.value
                      : "${(proxie as Group).type.value} [${proxie.now}]";
                  return ListTile(
                    visualDensity:
                        VisualDensity(vertical: VisualDensity.minimumDensity),
                    selected: groupNow == proxieName,
                    title: Text(
                      proxieName,
                      style: TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      subText,
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () => controller.select(
                      name: groupName,
                      select: proxieName,
                    ),
                    trailing: delay,
                  );
                },
              );
            }).toList(),
          ),
          floatingActionButton: Builder(
            builder: (context) {
              var _tabController = DefaultTabController.of(context);
              return FloatingActionButton(
                tooltip: "测延迟",
                onPressed: () => testDelay(_tabController),
                child: Icon(Icons.flash_on),
              );
            },
          ),
        ),
      );
    });
  }
}
