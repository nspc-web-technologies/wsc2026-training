import { createRouter, createWebHistory } from "vue-router";
import CarparksView from "../views/CarparksView.vue";
import EventsView from "../views/EventsView.vue";
import WeathersView from "../views/WeathersView.vue";
import SettingsView from "../views/SettingsView.vue";

export default createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: "/",
            redirect: "/carparks"
        },
        {
            path: "/carparks",
            component: CarparksView,
        },
        {
            path: "/events",
            component: EventsView,
        },
        {
            path: "/weathers",
            component: WeathersView,
        },
        {
            path: "/settings",
            component: SettingsView,
        },
    ]
});